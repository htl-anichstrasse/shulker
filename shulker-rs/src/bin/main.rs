use std::{
    io::{BufRead, BufReader},
    path::PathBuf,
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

use crossbeam_channel::{Receiver, Sender};
use interprocess::local_socket::{LocalSocketListener, LocalSocketStream};
use json::JsonValue;
use shulker_rs::{credential_types::Secret, shulker_db::ShulkerDB};
use sixtyfps::Weak;
use std::io::Write;

sixtyfps::include_modules!();
fn main() {
    let (s0, r0) = crossbeam_channel::bounded::<JsonValue>(0);
    let (s1, r1) = crossbeam_channel::unbounded();

    let ui = MainUi::new();
    let ui_handle = ui.as_weak();
    let shulker_core_lock = Arc::new(Mutex::new(ShulkerCore::new(ui_handle.clone(), s0.clone())));

    //Server Communication Socket Thread - Receive
    let shulker_core_lock3 = shulker_core_lock.clone();
    let s1_clone = s1.clone();
    let server_thread_handle = thread::spawn(move || {
        let core_socket_path = shulker_rs::CONFIGURATION
            .read()
            .unwrap()
            .get_str("receive_socket_path")
            .unwrap();
        while let Some(e) = match std::fs::remove_file(&core_socket_path) {
            Ok(_) => Some(()),
            Err(_) => None,
        } {
            thread::sleep(Duration::from_millis(200));
        }

        let listener = LocalSocketListener::bind(core_socket_path).unwrap();
        for mut conn in listener.incoming().filter_map(|c| {
            c.map_err(|error| eprintln!("Incoming connection failed: {}", error))
                .ok()
        }) {
            let mut conn = BufReader::new(conn);
            let mut buffer = String::new();
            loop {
                buffer.clear();
                match conn.read_line(&mut buffer) {
                    Ok(size) => {
                        if size == 0 {
                            break;
                        }
                    }
                    Err(error) => {
                        println!("{:#?}", error);
                        break;
                    }
                };

                let msg = match json::parse(&buffer.trim()) {
                    Ok(msg) => msg,
                    Err(_) => {
                        continue;
                    }
                };
                let mut answer = None;
                {
                    let mut shulker_core = shulker_core_lock3.lock().unwrap();
                    answer = shulker_core.handle_message(msg);
                }
                s1_clone.send(answer).unwrap();
            }
        }
    });

    // Server Communication Socket Thread - Send
    let r1_clone = r1.clone();
    let send_thread_handler = thread::spawn(move || {
        let server_socket_path = shulker_rs::CONFIGURATION
            .read()
            .unwrap()
            .get_str("send_socket_path")
            .unwrap();

        loop {
            let mut conn = match LocalSocketStream::connect(&*server_socket_path) {
                Ok(conn) => conn,
                Err(e) => {
                    println!("ERROR: {:#?}", e);
                    println!("Failed to receive connection, retrying in 3 seconds.");
                    std::thread::sleep(Duration::from_secs(3));
                    continue;
                }
            };
            loop {
                let answer = match r1_clone.recv().unwrap() {
                    Some(answer) => answer,
                    None => continue,
                };

                match conn.write_all(json::stringify(answer).as_bytes()) {
                    Ok(_) => (),
                    Err(e) => {
                        println!("Connection write error: {:#?}", e);
                        break;
                    }
                };
            }
        }
    });

    // Display Communication Thread
    let ui_handle_clone = ui_handle.clone();
    let shulker_core_lock2 = shulker_core_lock.clone();
    let thread_handler_1 = thread::spawn(move || loop {
        let msg = r0.recv().unwrap();
        let response;
        {
            let mut shulker_core = shulker_core_lock2.lock().unwrap();
            response = (*shulker_core).handle_message(msg);
        }
    });

    // UI Event Handlers
    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_pin_try(move |code| {
        let ui = ui_handle_clone.unwrap();
        let msg = json::object! {
            request: "USE PIN",
            secret: code.as_str(),
        };
        s0_clone.send(msg).unwrap();
    });

    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_password_try(move |code| {
        let ui = ui_handle_clone.unwrap();
        let msg = json::object! {
            request: "USE PASSWORD",
            secret: code.as_str(),
        };
        s0_clone.send(msg).unwrap();
    });

    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_lock(move || {
        let ui = ui_handle_clone.unwrap();
        let msg = json::object! {
            request: "LOCK",
        };
        s0_clone.send(msg).unwrap();
    });

    ui.run();
    thread_handler_1.join().unwrap();
    server_thread_handle.join().unwrap();
    send_thread_handler.join().unwrap();
}

pub struct ShulkerCore<'a> {
    is_locked: bool,
    shulker_db: ShulkerDB<'a>,
    ui_handle: Weak<MainUi>,
    s0: Sender<JsonValue>,
    a_s: Sender<String>,
    a_r: Receiver<String>,
    autolock_seconds: i32,
}

impl ShulkerCore<'_> {
    pub fn new(ui_handle: Weak<MainUi>, s0: Sender<JsonValue>) -> Self {
        let (a_s, a_r) = crossbeam_channel::unbounded();

        ShulkerCore {
            is_locked: true,
            shulker_db: ShulkerDB::new(PathBuf::from("credentials")),
            ui_handle,
            s0,
            a_s,
            a_r,
            autolock_seconds: shulker_rs::CONFIGURATION
                .read()
                .unwrap()
                .get_int("autolock_seconds")
                .unwrap() as i32,
        }
    }

    pub fn handle_message(&mut self, msg: JsonValue) -> Option<JsonValue> {
        println!("{:#?}", msg);
        let request = match &msg["request"] {
            JsonValue::String(request) => request.clone(),
            JsonValue::Short(request) => request.to_string(),
            _ => return None,
        };

        match request.as_str() {
            "LOCK" => {
                self.lock();
            }
            "UNLOCK" => {
                self.unlock();
            }
            "USE PIN" => {
                let secret = match &msg["secret"] {
                    JsonValue::String(request) => request.clone(),
                    JsonValue::Short(request) => request.to_string(),
                    _ => return None,
                };
                if self.try_secret(Secret::PinCode(secret)) {
                    self.unlock();
                    return Some(json::object! {
                        answer: "UNLOCKED",
                    });
                } else {
                    return Some(json::object! {
                        answer: "WRONG SECRET",
                    });
                }
            }
            "USE PASSWORD" => {
                let secret = match &msg["secret"] {
                    JsonValue::String(request) => request.clone(),
                    JsonValue::Short(request) => request.to_string(),
                    _ => return None,
                };
                if self.try_secret(Secret::Password(secret)) {
                    self.unlock();
                    return Some(json::object! {
                        answer: "UNLOCKED",
                    });
                } else {
                    return Some(json::object! {
                        answer: "WRONG SECRET",
                    });
                }
            }
            _ => {}
        }
        None
    }

    fn lock(&mut self) {
        self.is_locked = true;
        let ui_handle = self.ui_handle.clone();
        sixtyfps::invoke_from_event_loop(move || {
            ui_handle.unwrap().set_locked(true);
        });
        self.a_s.send("LOCKED".to_string()).unwrap();
    }

    fn unlock(&mut self) {
        self.is_locked = false;
        let ui_handle = self.ui_handle.clone();
        sixtyfps::invoke_from_event_loop(move || {
            ui_handle.unwrap().set_locked(false);
        });
        while !self.a_r.is_empty() {
            self.a_r.recv().unwrap();
        }
        let ui_handle = self.ui_handle.clone();
        let s0 = self.s0.clone();
        let secs = self.autolock_seconds;
        let a_r = self.a_r.clone();
        thread::spawn(move || {
            autolock(secs, s0, ui_handle, a_r);
        });
    }

    fn try_secret(&mut self, secret: Secret) -> bool {
        self.shulker_db.use_credential(secret).unwrap()
    }
}

pub fn autolock(
    seconds: i32,
    s0: Sender<JsonValue>,
    ui_handle: Weak<MainUi>,
    a_r: Receiver<String>,
) {
    for x in 0..seconds {
        if !a_r.is_empty() {
            return;
        }
        let ui_handle_clone = ui_handle.clone();
        sixtyfps::invoke_from_event_loop(move || {
            ui_handle_clone.unwrap().set_autolock_seconds(seconds - x)
        });
        thread::sleep(Duration::from_secs(1));
    }
    let msg = json::object! {
        request: "LOCK",
    };
    s0.send(msg).unwrap();
}
