use std::path::PathBuf;

use crate::{messaging::Command, shulker_db::ShulkerDB};

pub struct ShulkerCore<'a> {
    shulker_db: ShulkerDB<'a>,
    locked: bool,
}

impl ShulkerCore<'_> {
    pub fn new() -> Self {
        ShulkerCore {
            shulker_db: ShulkerDB::new(PathBuf::from("credentials")),
            locked: true,
        }
    }

    pub fn lock(&mut self) {
        self.locked = true;
    }

    fn unlock(&mut self) {
        self.locked = false;
    }

    pub fn handle_command(&mut self, cmd: Command) -> Option<Command> {
        println!("{:#?}", cmd);
        // TODO
        None
    }
}
