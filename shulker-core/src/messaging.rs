use std::{
    io::{BufRead, BufReader, Write},
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

use chrono::{DateTime, Utc};
use crossbeam_channel::{Receiver, Sender};
use interprocess::local_socket::{LocalSocketListener, LocalSocketStream};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{core::ShulkerCore, credential_types::Credential, CONFIGURATION};

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "method")]
pub enum Command {
    //GENERAL
    Lock,
    Unlock,
    Status,
    Failed,
    Created,
    Removed,
    Locked,
    Unlocked,
    Wrong,
    Correct,
    QrCode { data: String },

    //MASTER
    UseMaster { secret: String },

    //PINS
    CreatePin { pin: Credential },
    DeletePin { uuid: Uuid },
    GetPins,
    PinList { pins: Vec<CredentialNoSecret> },
    UsePin { secret: String },
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq, Debug)]
pub struct CredentialNoSecret {
    pub label: String,
    pub uuid: Uuid,
    pub start_time: DateTime<Utc>,
    pub end_time: DateTime<Utc>,
    pub uses_left: i32,
}

pub fn listen(core: Arc<Mutex<ShulkerCore>>, sender: Sender<Command>) {
    let socket_path = CONFIGURATION
        .read()
        .unwrap()
        .get_str("receive_socket_path")
        .unwrap();

    while let Some(_e) = match std::fs::remove_file(&socket_path) {
        Ok(_) => Some(()),
        Err(_) => None,
    } {
        thread::sleep(Duration::from_millis(200));
    }

    let listener = LocalSocketListener::bind(socket_path).unwrap();
    for connection in listener.incoming().filter_map(|r| {
        r.map_err(|error| eprintln!("Incoming connection failed: {}", error))
            .ok()
    }) {
        let mut connection = BufReader::new(connection);
        let mut buffer = String::new();

        loop {
            buffer.clear();
            match connection.read_line(&mut buffer) {
                Ok(size) => {
                    if size == 0 {
                        break;
                    }
                }
                Err(error) => {
                    eprintln!("{:#?}", error);
                    break;
                }
            };

            let cmd: Command = match serde_json::from_str(buffer.as_str()) {
                Ok(cmd) => cmd,
                Err(error) => {
                    eprintln!("Invalid command: {:#?}", error);
                    break;
                }
            };

            let answer: Option<Command>;
            {
                let mut unlocked_core = core.lock().expect("Unable to aquire core lock!");
                answer = unlocked_core.handle_command(cmd);
            }
            if let Some(cmd) = answer {
                match sender.send(cmd) {
                    Ok(_) => (),
                    Err(e) => {
                        eprintln!("Answer-Channel closed? (sender): {:?}", e);
                        return;
                    }
                }
            }
        }
    }
}

pub fn tell(_core: Arc<Mutex<ShulkerCore>>, receiver: Receiver<Command>) {
    let socket_path = CONFIGURATION
        .read()
        .unwrap()
        .get_str("send_socket_path")
        .unwrap();

    loop {
        let mut connection = match LocalSocketStream::connect(&*socket_path) {
            Ok(connection) => connection,
            Err(error) => {
                eprintln!("ERROR {}", error);
                eprintln!("Failed  to receive connection, retrying in 3 seconds.");
                thread::sleep(Duration::from_secs(3));
                continue;
            }
        };
        loop {
            let answer = match receiver.recv() {
                Ok(answer) => answer,
                Err(e) => {
                    eprintln!("Answer-Channel closed? (receiver): {:?}", e);
                    return;
                }
            };

            match connection.write_all(
                serde_json::to_string(&answer)
                    .expect("Couldn't serialize answer!")
                    .as_bytes(),
            ) {
                Ok(_) => (),
                Err(e) => {
                    eprintln!("Unable to write to connection: {:?}.", e);
                    break;
                }
            }
        }
    }
}
