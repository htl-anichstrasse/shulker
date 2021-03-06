slint::include_modules!();
use crate::core::ShulkerCore;
use std::{
    sync::{Arc, Mutex, RwLock},
    thread::{self, spawn},
    time::Duration,
};

use config::{Config, File};
use std::path::Path;

use lazy_static::lazy_static;
use messaging::Command;
use slint::Image;

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
            .set_default("autolock_seconds", 24)
            .unwrap()
            .set_default("receive_socket_path", "/tmp/toShulkerCore.sock")
            .unwrap()
            .set_default("send_socket_path", "/tmp/toShulkerServer.sock")
            .unwrap()
            .set_default("gpio_pin", 27)
            .unwrap()
            .set_default("master_password", "master123")
            .unwrap()
            .set_default("qr_code_link", "not setup!")
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
    let mut count = 0;
    while let Some(_e) = match std::fs::remove_file("qr_code.png") {
        Ok(_) => Some(()),
        Err(_) => None,
    } {
        thread::sleep(Duration::from_millis(200));
        if count >= 10 {
            panic!("Unable to delete qr_code file!");
        }
        count += 1;
    }

    let code = crate::CONFIGURATION
            .read()
            .unwrap()
            .get_str("qr_code_link")
            .unwrap();

    qrcode_generator::to_png_to_file_from_str(code, qrcode_generator::QrCodeEcc::Medium, 1024, "qr_code.png").unwrap();

    let ui = MainWindow::new();
    let core = Arc::new(Mutex::new(ShulkerCore::new(ui.as_weak())));

    /*{
        let mut lock = core.lock().unwrap();
        lock.shulker_db
            .add(credential_types::Credential {
                label: "TESTLABEL".to_string(),
                uuid: uuid::Uuid::new_v4(),
                start_time: Utc::now(),
                end_time: Utc.yo(9999, 10).and_hms(3, 3, 3),
                uses_left: 304,
                secret: "1234".to_string(),
            })
            .unwrap()
    }*/
    {
        let mut lock = core.lock().unwrap();
        lock.lock();
    }
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

    let ui_handle = ui.as_weak();
    ui_handle.upgrade_in_event_loop(move |ui| {
        while !Path::new("qr_code.png").exists() {
            std::thread::sleep(Duration::from_millis(100));
        }
        let qr = ui.global::<qr_code_ui>();
        qr.set_qr_code(match Image::load_from_path(Path::new("qr_code.png")) {
            Ok(qr) => qr,
            Err(_e) => panic!("Unable to set QrCode Image"),
        });
    });

    ui.run();
    {
        let mut lock = core.lock().unwrap();
        lock.shulker_db.save();
    }
    std::fs::remove_file("qr_code.png").unwrap()
}
