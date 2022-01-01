// ONLY FOR TESTING PURPOSES

use std::{env, path::PathBuf, sync::mpsc::channel, ops::Add};
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::{ShulkerDB, self}};
use uuid::Uuid;

sixtyfps::include_modules!();
fn main() {
    let (tx, rx) = channel::<String>();
    let handler = std::thread::spawn(move || {
        let mut shulker_db = shulker_db::ShulkerDB::new(PathBuf::from("credentials"));
        shulker_db.add(Credential { uuid: Uuid::new_v4(), time_frame: None, uses_left: None, secret: Secret::PinCode("123450".to_string()) }).unwrap();

        loop {
            let received_string = rx.recv().unwrap();
            println!("{:#?}", received_string);

            let cmd: Vec<&str> = received_string.split(" ").collect();
            match cmd.len() {
                1 => {},
                2 => {},
                3 => {
                    match cmd[0] {
                        "PIN" => {
                            match cmd[1] {
                                "TRY" => {
                                    println!("TRIED CREDENTIAL - RESULT: {}", shulker_db.use_credential(Secret::PinCode(cmd[2].to_string())).unwrap());
                                }
                                _ => {}
                            }
                        }
                        _ => {}
                    }
                }
                _ => {}
            }
        }
    });
    let ui = MainUi::new();
    
    let ui_weak = ui.as_weak();
    let tx_clone = tx.clone();
    ui.on_pin_try(move |code| {
        let ui = ui_weak.unwrap();
        tx_clone.send(format!("PIN TRY {}", code)).unwrap();
    });

    let ui_weak = ui.as_weak();
    let tx_clone = tx.clone();
    ui.on_password_key_pressed(move |code| {
        let ui = ui_weak.unwrap();
        tx_clone.send(format!("PASSWORD KEY {}", code)).unwrap();
    });
    ui.run();
    handler.join().unwrap();
}
