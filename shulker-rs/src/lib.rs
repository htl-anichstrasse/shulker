use std::sync::RwLock;

use config::{Config, File};

sixtyfps::include_modules!();

#[macro_use]
extern crate lazy_static;

pub mod credential_types;
pub mod shulker_db;
pub mod hasher;

lazy_static! {
    pub static ref CONFIGURATION: RwLock<Config> = RwLock::new({
        let mut config = Config::default()
            .set_default("hash_memory_size", 10).unwrap()
            .set_default("hash_iterations", 3).unwrap()
            .set_default("hash_parallelism", 1).unwrap()
            .set_default("autolock_seconds", 24).unwrap()
            .set_default("receive_socket_path", "/tmp/toShulkerCore.sock").unwrap()
            .set_default("receive_socket_path", "/tmp/toShulkerServer.sock").unwrap()
            .clone();
        config.merge(File::with_name("config.toml")).expect("Couldn't load in config.toml!");
        config
    });
}