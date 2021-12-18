// ONLY FOR TESTING PURPOSES

use std::{env, path::PathBuf, sync::mpsc::channel};
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::ShulkerDB};
use uuid::Uuid;

sixtyfps::include_modules!();
fn main() {
    let (tx, rx) = channel();
    let handler = std::thread::spawn(move || {
        println!("{:#?}", rx.recv());
        
    });
    tx.send("TEST").unwrap();
    MainUi::new().run();
    handler.join().unwrap();
}
