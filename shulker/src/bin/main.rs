// ONLY FOR TESTING PURPOSES

use std::{env};

use shulker::{credential_types::{Credential, Secret}, shulker_db::{ShulkerDB}};
use uuid::Uuid;


fn main() {
    let current_dir = env::current_dir().unwrap();
    let mut shulker_db = ShulkerDB::new(current_dir.with_file_name("credentials"));
    shulker_db.add(Credential {
        uuid: Uuid::new_v4(),
        time_frame: None,
        uses_left: Some(2),
        secret: Secret::Password(String::from("passwort123")),
    }).unwrap();
    let correct = shulker_db.use_credential(Secret::Password(String::from("passwort123")));

    println!("{:#?}", correct);
}