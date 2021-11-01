// ONLY FOR TESTING PURPOSES

use std::{env};
use shulker_rs::{credential_types::{Credential, Secret}, shulker_db::ShulkerDB};
use uuid::Uuid;


fn main() {
    let current_dir = env::current_dir().unwrap();
    let mut shulker_db = ShulkerDB::new(current_dir.with_file_name("credentials"));
    let uuid = Uuid::new_v4();
    shulker_db.add(Credential {
        uuid,
        time_frame: None,
        uses_left: Some(2),
        secret: Secret::PinCode(String::from("32")),
    }).unwrap();
    let correct = shulker_db.get_all(Some(Secret::PinCode(String::new()))).unwrap();

    println!("{:#?}", correct);
}
