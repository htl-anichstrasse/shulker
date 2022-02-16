use std::path::PathBuf;

use slint::{Weak, Timer};

use crate::{credential_types::Secret, messaging::Command, shulker_db::ShulkerDB, MainWindow};

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
            Command::Lock() => {
                self.lock();
                Some(Command::Locked())
            }
            Command::Unlock() => {
                self.unlock();
                Some(Command::Unlocked())
            }
            Command::UsePin(secret) => {
                let is_correct = self
                    .shulker_db
                    .use_credential(Secret::PinCode(secret))
                    .expect("Rustbreakerror!");

                if is_correct {
                    self.unlock();
                    return Some(Command::Unlocked());
                }
                Some(Command::Wrong())
            }
            Command::UsePassword(secret) => {
                let is_correct = self
                    .shulker_db
                    .use_credential(Secret::Password(secret))
                    .expect("Rustbreakerror!");

                if is_correct {
                    self.unlock();
                    return Some(Command::Unlocked());
                }
                Some(Command::Wrong())
            }
            Command::UseMaster(_) => todo!(),
            _ => None,
        }
    }
}
