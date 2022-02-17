use std::path::PathBuf;

use slint::Weak;

use crate::{messaging::Command, shulker_db::ShulkerDB, MainWindow};

pub struct ShulkerCore<'a> {
    pub shulker_db: ShulkerDB<'a>,
    pub locked: bool,
    ui_handle_weak: Weak<MainWindow>,
}

impl ShulkerCore<'_> {
    pub fn new(ui_handle_weak: Weak<MainWindow>) -> Self {
        ShulkerCore {
            shulker_db: ShulkerDB::new(PathBuf::from("credentials")),
            locked: true,
            ui_handle_weak,
        }
    }

    pub fn lock(&mut self) {
        self.locked = true;
        self.ui_handle_weak.upgrade_in_event_loop(move |ui| {
            ui.invoke_lockFromRust();
        });
    }

    fn unlock(&mut self) {
        self.locked = false;
        self.ui_handle_weak.upgrade_in_event_loop(move |ui| {
            ui.invoke_unlockFromRust();
            ui.invoke_startCountdown();
        });
    }

    pub fn handle_command(&mut self, cmd: Command) -> Option<Command> {
        match cmd {
            Command::Status => {
                if self.locked {
                    Some(Command::Locked)
                } else {
                    Some(Command::Unlocked)
                }
            }
            Command::Lock => {
                self.lock();
                Some(Command::Locked)
            }
            Command::Unlock => {
                self.unlock();
                Some(Command::Unlocked)
            }
            Command::UsePin { secret } => {
                let is_correct = self
                    .shulker_db
                    .use_credential(secret)
                    .expect("Rustbreakerror!");

                if is_correct {
                    self.unlock();
                    return Some(Command::Unlocked);
                }
                Some(Command::Wrong)
            }
            Command::GetPins => {
                let pins = match self.shulker_db.get_all() {
                    Ok(c) => c,
                    Err(e) => panic!("Unable to get pins: {}", e),
                };
                Some(Command::PinList { pins })
            }
            Command::CreatePin { pin } => match self.shulker_db.add(pin) {
                Ok(()) => Some(Command::Created),
                Err(e) => {
                    eprintln!("Unable to create pin: {}", e);
                    Some(Command::Failed)
                }
            },
            Command::DeletePin { uuid } => match self.shulker_db.remove(uuid) {
                Ok(deleted) => {
                    if deleted {
                        Some(Command::Removed)
                    } else {
                        Some(Command::Failed)
                    }
                }
                Err(e) => {
                    eprintln!("Unable to remove pin: {}", e);
                    Some(Command::Failed)
                }
            },
            Command::UseMaster { secret } => {
                if self.shulker_db.use_master(secret) {
                    Some(Command::Correct)
                } else {
                    Some(Command::Wrong)
                }
            }
            _ => None,
        }
    }
}
