use std::{path::{PathBuf}};
use serde::{Serialize, Deserialize};
use rustbreak::{Database, PathDatabase, RustbreakError, backend::PathBackend};
use rustbreak::deser::Bincode;

use crate::credential_types::{Credential, Secret};

pub struct ShulkerDB {
    rustbreak: Database<Credentials, PathBackend, Bincode>,
}

impl ShulkerDB {
    pub fn new(file_path: PathBuf) -> Self {
        let path_clone = file_path.clone();
        let rustbreak = PathDatabase::<Credentials, Bincode>::create_at_path(file_path, Credentials { data: Vec::new() })
            .expect(&format!("Unable to create/open file at {:?}", path_clone));
        
        ShulkerDB {
            rustbreak,
        }
    }

    pub fn add(&mut self, credential: Credential) -> Result<(), RustbreakError> {
        self.rustbreak.load()?;
        self.rustbreak.write_safe(|db| {
            db.add(credential);
        })?;
        self.rustbreak.save()?;
        Ok(())
    }

    pub fn use_credential(&mut self, user_input: Secret) -> Result<bool, RustbreakError> {
        let mut credentials = self.rustbreak.get_data(true)?;
        match user_input {
            Secret::PinCode(pin_code) => {
                for c in &mut credentials.data {
                    if let Secret::PinCode(secret) = c.secret.clone() {
                        if secret == pin_code && c.check_if_useable() {
                            c.reduce_uses();
                            self.rustbreak.put_data(credentials, true)?;
                            return Ok(true);
                        }
                    }
                }
            },
            Secret::Password(password) => {
                for c in &mut credentials.data {
                    if let Secret::Password(secret) = c.secret.clone() {
                        if secret == password && c.check_if_useable() {
                            c.reduce_uses();
                            self.rustbreak.put_data(credentials, true)?;
                            return Ok(true);
                        }
                    }
                }
            },
        }
        Ok(false)
    }
}



#[derive(Clone, Serialize, Deserialize)]
pub struct Credentials {
    data: Vec<Credential>,
}

impl Credentials {
    pub fn add(&mut self, credential: Credential) {
        self.data.push(credential);
    }
}