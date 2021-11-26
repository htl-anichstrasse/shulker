use std::{convert::TryInto, sync::RwLock};

use config::{Config, File};

#[macro_use]
extern crate lazy_static;

pub mod credential_types;
pub mod shulker_db;
pub mod hasher;

lazy_static! {
    static ref CONFIGURATION: RwLock<Config> = RwLock::new({
        let mut config = Config::default()
            .set_default("hash_memory_size", 10).unwrap()
            .set_default("hash_iterations", 3).unwrap()
            .set_default("hash_parallelism", 1).unwrap()
            .clone();
        config.merge(File::with_name("config.toml")).expect("Couldn't load in config.toml!");
        config
    });
}