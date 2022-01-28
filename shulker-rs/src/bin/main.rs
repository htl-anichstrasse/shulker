use std::{sync::{Arc, Mutex}, thread, time::Duration, path::PathBuf, io::Read, str::FromStr};

use byteorder::{BigEndian, ReadBytesExt};
use crossbeam_channel::{Sender, Receiver};
use ipipe::Pipe;
use shulker_rs::{shulker_db::ShulkerDB, credential_types::Secret};
use sixtyfps::Weak;
use std::io::Write;

sixtyfps::include_modules!();
fn main() {
    let (s0, r0) = crossbeam_channel::bounded::<String>(0);

    let ui = MainUi::new();
    let ui_handle = ui.as_weak();
    let shulker_core_lock = Arc::new(Mutex::new(ShulkerCore::new(ui_handle.clone(), s0.clone())));
    
    // Display Communication Thread
    let ui_handle_clone = ui_handle.clone();
    let shulker_core_lock2 = shulker_core_lock.clone();
    let thread_handler_1 = thread::spawn(move || {
        loop {
            let msg = r0.recv().unwrap();
            let response;
            {
                let mut shulker_core = shulker_core_lock2.lock().unwrap();
                response = (*shulker_core).handle_message(msg);
            }
            if response.is_none() { continue }
            let response = response.unwrap();
        }
    });

    let mut _pipe = Pipe::open(&PathBuf::from_str("shulker_pipe").unwrap(), ipipe::OnCleanup::Delete).unwrap();
    let mut pipe = _pipe.clone();
    // Named Pipe Communication Thread
    let ui_handle_clone = ui_handle.clone();
    let shulker_core_lock2 = shulker_core_lock.clone();
    let thread_handler_2 = thread::spawn(move || {
        loop {
            let msg = decode_msg(&mut pipe);
            println!("{:#?}", msg);
        }
    });

    let mut pipe = _pipe.clone();
    // Test Thread
    thread::spawn(move || {
        
        loop {
            thread::sleep(Duration::from_secs(1));
            let msg = "TEST MESSAGE";
            let len = msg.bytes().len() as u32 - 3 as u32;
            pipe.write(&len.to_be_bytes()).unwrap();
            write!(&mut pipe, "{}", msg).unwrap();
        }
    });

    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_pin_try(move |code| {
        let ui = ui_handle_clone.unwrap();
        s0_clone.send(format!("PIN TRY {}", code)).unwrap();
    });

    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_password_try(move |code| {
        let ui = ui_handle_clone.unwrap();
        s0_clone.send(format!("PASSWORD TRY {}", code)).unwrap();
    });

    let ui_handle_clone = ui_handle.clone();
    let s0_clone = s0.clone();
    ui.on_lock(move || {
        let ui = ui_handle_clone.unwrap();
        s0_clone.send("LOCK".to_string()).unwrap();
    });

    ui.run();
    thread_handler_1.join().unwrap();
    thread_handler_2.join().unwrap();
}


pub struct ShulkerCore<'a> {
    is_locked: bool,
    shulker_db: ShulkerDB<'a>,
    ui_handle: Weak<MainUi>,
    s0: Sender<String>,
    a_s: Sender<String>,
    a_r: Receiver<String>,
    autolock_seconds: i32,
}

impl ShulkerCore<'_> {
    pub fn new(ui_handle: Weak<MainUi>, s0: Sender<String>) -> Self {
        let (a_s, a_r) = crossbeam_channel::unbounded();

        ShulkerCore {
            is_locked: true,
            shulker_db: ShulkerDB::new(PathBuf::from("credentials")),
            ui_handle,
            s0,
            a_s,
            a_r,
            autolock_seconds: shulker_rs::CONFIGURATION.read().unwrap().get_int("autolock_seconds").unwrap() as i32,
        }
    }

    pub fn handle_message(&mut self, msg: String) -> Option<String>{
        let msg: Vec<&str> = msg.split(" ").collect();
        if msg.len() < 1 { return None };
        
        match msg.len() {
            1 => {
                match msg[0] {
                    "LOCK" => {
                        self.lock();
                        return Some("LOCKED".to_string());
                    },
                    "UNLOCK" => {
                        self.unlock();
                        return Some("UNLOCKED".to_string());
                    },
                    _ => {},
                }
            },
            2 => {},
            3 => {
                match msg[0] {
                    "PIN" => {
                        if msg[1] == "TRY" {
                            if self.try_secret(Secret::PinCode(msg[2].to_string())) {
                                self.unlock();
                                return Some("UNLOCKED".to_string());
                            }
                        }
                    },
                    "PASSWORD" => {
                        if msg[1] == "TRY" {
                            if self.try_secret(Secret::Password(msg[2].to_string())) {
                                self.unlock();
                                return Some("UNLOCKED".to_string());
                            }
                        }
                    },
                    _ => {},
                }
            },
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



pub fn autolock(seconds: i32, s0: Sender<String>, ui_handle: Weak<MainUi>, a_r: Receiver<String>) {
    for x in 0..seconds {
        if !a_r.is_empty() { return }
        let ui_handle_clone = ui_handle.clone();
        sixtyfps::invoke_from_event_loop(move || ui_handle_clone.unwrap().set_autolock_seconds(seconds - x));
        thread::sleep(Duration::from_secs(1));
    }
    s0.send("LOCK".to_string()).unwrap();
}

pub fn decode_msg(pipe: &mut Pipe) -> String {
    let msg_len = pipe.read_u32::<BigEndian>().unwrap();
    let mut msg_buf = vec![0u8; msg_len as usize];
    pipe.read_exact(&mut msg_buf).unwrap();
    String::from_utf8(msg_buf).unwrap()
}