// ONLY FOR TESTING PURPOSES

use std::{env, path::PathBuf};
use argon2::{Argon2, Params, PasswordHash, PasswordHasher, PasswordVerifier, password_hash::SaltString};
use rand_core::OsRng;
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::ShulkerDB};
use uuid::Uuid;


fn main() {
    let current_dir = env::current_dir().unwrap();
    let mut shulker_db = ShulkerDB::new(PathBuf::from("credentials.skr"));

    let credential_1 = Credential {
        uuid: Uuid::new_v4(),
        time_frame: None,
        uses_left: None,
        secret: Secret::PinCode(String::from("32142")),
    };
    let credential_2 = Credential {
        uuid: Uuid::new_v4(),
        time_frame: None,
        uses_left: None,
        secret: Secret::Password(String::from("alexander")),
    };
    let credential_3 = Credential {
        uuid: Uuid::new_v4(),
        time_frame: None,
        uses_left: None,
        secret: Secret::Password(String::from("449")),
    };
    shulker_db.add(credential_1).unwrap();
    shulker_db.add(credential_2).unwrap();
    shulker_db.add(credential_3).unwrap();

    println!("{:#?}", shulker_db.get_all(None));
}
