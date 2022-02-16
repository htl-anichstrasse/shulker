slint::include_modules!();
use crate::core::ShulkerCore;
use std::{
    sync::{Arc, Mutex, RwLock},
    thread::spawn,
};

use config::{Config, File};

use lazy_static::lazy_static;
use messaging::Command;

mod core;
mod credential_types;
mod hasher;
mod messaging;
mod shulker_db;

// CONFIG
lazy_static! {
    static ref CONFIGURATION: RwLock<Config> = RwLock::new({
        let mut config = Config::default()
            .set_default("hash_memory_size", 10)
            .unwrap()
            .set_default("hash_iterations", 3)
            .unwrap()
            .set_default("hash_parallelism", 1)
            .unwrap()
            .set_default("autlock_seconds", 24)
            .unwrap()
            .set_default("receive_socket_path", "/tmp/toShulkerCore.sock")
            .unwrap()
            .set_default("send_socket_path", "/tmp/toShulkerServer.sock")
            .unwrap()
            .set_default("master_password", "master123")
            .unwrap()
            .clone();

        match config.merge(File::with_name("config.toml")) {
            Ok(_) => (),
            Err(_) => {
                eprintln!("WARNING: Couldn't load config.toml, using default config.");
            }
        };
        config
    });
}

fn main() {
    let ui = MainWindow::new();
    let core = Arc::new(Mutex::new(ShulkerCore::new(ui.as_weak())));

    let (messaging_channel_sender, messagin_channel_receiver) =
        crossbeam_channel::bounded::<Command>(0);

    let core_clone = core.clone();
    let _listener_handle = spawn(move || {
        messaging::listen(core_clone, messaging_channel_sender);
    });

    let core_clone = core.clone();
    let _teller_handle = spawn(move || {
        messaging::tell(core_clone, messagin_channel_receiver);
    });

    // UI Event Handlers
    let _ui_handle = ui.as_weak();
    let core_clone = core.clone();
    ui.on_use_pin(move |secret| {
        let answer;
        let cmd = Command::UsePin {
            secret: secret.to_string(),
        };
        {
            let mut lock = core_clone
                .lock()
                .expect("Unable to lock core (on_use_pin)!");
            answer = lock.handle_command(cmd);
        }
        let _answer = match answer {
            Some(cmd) => cmd,
            None => return,
        };
    });

    let _ui_handle = ui.as_weak();
    let core_clone = core.clone();
    ui.on_use_password(move |secret| {
        let answer;
        let cmd = Command::UsePin {
            secret: secret.to_string(),
        };
        {
            let mut lock = core_clone
                .lock()
                .expect("Unable to lock core (on_use_pin)!");
            answer = lock.handle_command(cmd);
        }
        let _answer = match answer {
            Some(cmd) => cmd,
            None => return,
        };
    });

    let ui_handle = ui.as_weak();
    let core_clone = core.clone();
    ui.on_lock(move || {
        {
            let mut lock = core_clone
                .lock()
                .expect("Unable to lock core (on_use_pin)!");
            lock.lock();
        }
        let _handle_copy = ui_handle.clone();
        ui_handle.upgrade_in_event_loop(move |handle_copy| handle_copy.invoke_lockFromRust());
    });

    ui.run();
}