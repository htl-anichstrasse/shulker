// ONLY FOR TESTING PURPOSES

use std::{env, path::PathBuf};
use argon2::{Argon2, Params, PasswordHash, PasswordHasher, PasswordVerifier, password_hash::SaltString};
use rand_core::OsRng;
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::ShulkerDB};
use uuid::Uuid;


fn main() {
    let current_dir = env::current_dir().unwrap();
    let password = "1234";
    let shulker_db = ShulkerDB::new(PathBuf::from("credentials.skr"));
    
}
