// ONLY FOR TESTING PURPOSES

use std::{env, path::PathBuf, sync::{mpsc::channel, Arc, Mutex}, ops::Add};
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::{ShulkerDB, self}};
use uuid::Uuid;

sixtyfps::include_modules!();
fn main() {
    let mut locked: Arc<Mutex<bool>> = Arc::new(Mutex::new(true));
    let mut locked_clone = locked.clone();
    let (tx, rx) = channel::<String>();

    let ui = MainUi::new();
    let ui_weak = ui.as_weak();

    let handler = std::thread::spawn(move || {
        let mut shulker_db = shulker_db::ShulkerDB::new(PathBuf::from("credentials"));
        shulker_db.add(Credential { uuid: Uuid::new_v4(), time_frame: None, uses_left: None, secret: Secret::Password("ABC399".to_string()) }).unwrap();

        loop {
            let received_string = rx.recv().unwrap();
            println!("{:#?}", received_string);

            let cmd: Vec<&str> = received_string.split(" ").collect();
            match cmd.len() {
                1 => {
                    match cmd[0] {
                        "LOCK" => {
                            let mut lock = locked_clone.lock().unwrap();
                            *lock = true;
                            let handle_copy = ui_weak.clone();
                            sixtyfps::invoke_from_event_loop(move || handle_copy.unwrap().set_locked(true));
                        }
                        _ => {},
                    }
                },
                2 => {},
                3 => {
                    match cmd[0] {
                        "PIN" => {
                            match cmd[1] {
                                "TRY" => {
                                    if shulker_db.use_credential(Secret::PinCode(cmd[2].to_string())).unwrap() {
                                        let mut lock = locked_clone.lock().unwrap();
                                        *lock = false;
                                        let handle_copy = ui_weak.clone();
                                        sixtyfps::invoke_from_event_loop(move || handle_copy.unwrap().set_locked(false));
                                    };
                                }
                                _ => {}
                            }
                        },
                        "PASSWORD" => {
                            match cmd[1] {
                                "TRY" => {
                                    if shulker_db.use_credential(Secret::Password(cmd[2].to_string())).unwrap() {
                                        let mut lock = locked_clone.lock().unwrap();
                                        *lock = false;
                                        let handle_copy = ui_weak.clone();
                                        sixtyfps::invoke_from_event_loop(move || handle_copy.unwrap().set_locked(false));
                                    }
                                },
                                _ => {}
                            }
                        },
                        _ => {}
                    }
                }
                _ => {}
            }
        }
    });
    
    let ui_weak = ui.as_weak();
    let tx_clone = tx.clone();
    ui.on_pin_try(move |code| {
        let ui = ui_weak.unwrap();
        tx_clone.send(format!("PIN TRY {}", code)).unwrap();
    });

    let ui_weak = ui.as_weak();
    let tx_clone = tx.clone();
    ui.on_password_try(move |code| {
        let ui = ui_weak.unwrap();
        tx_clone.send(format!("PASSWORD TRY {}", code)).unwrap();
    });

    let ui_weak = ui.as_weak();
    let tx_clone = tx.clone();
    ui.on_lock(move || {
        let ui = ui_weak.unwrap();
        tx_clone.send("LOCK".to_string()).unwrap();
    });
    ui.run();
    
    handler.join().unwrap();
}
