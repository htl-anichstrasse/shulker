use std::{path::{PathBuf}};
use serde::{Serialize, Deserialize};
use rustbreak::{Database, PathDatabase, RustbreakError, backend::PathBackend};
use rustbreak::deser::Bincode;
use uuid::Uuid;

use crate::{credential_types::{Credential, Secret}, hasher::Hasher};

pub struct ShulkerDB<'a> {
    rustbreak: Database<Credentials, PathBackend, Bincode>,
    hasher: Hasher<'a>,
}

impl<'a> ShulkerDB<'a> {
    pub fn new(file_path: PathBuf) -> Self {
        let path_clone = file_path.clone();
        let rustbreak = PathDatabase::<Credentials, Bincode>::create_at_path(file_path, Credentials { data: Vec::new() })
            .expect(&format!("Unable to create/open file at {:?}", path_clone));
        
        ShulkerDB {
            rustbreak,
            hasher: Hasher::new(),
        }
    }

    fn hash_secret(&mut self, secret: Secret) -> Secret {
        match secret {
            Secret::PinCode(secret_string) => {
                Secret::PinCode(self.hasher.hash(secret_string.as_bytes()))
            },
            Secret::Password(secret_string) => {
                Secret::Password(self.hasher.hash(secret_string.as_bytes()))
            },
        }
    }

    pub fn add(&mut self, mut credential: Credential) -> Result<(), RustbreakError> {
        self.rustbreak.load()?;
        credential.secret = self.hash_secret(credential.secret);
        self.rustbreak.write_safe(|db| {
            db.add(credential);
        })?;
        self.rustbreak.save()?;
        Ok(())
    }

    pub fn remove(&mut self, uuid: Uuid) -> Result<(), RustbreakError> {
        self.rustbreak.load()?;
        self.rustbreak.write_safe(|db| {
            db.remove(uuid);
        })?;
        self.rustbreak.save()?;
        Ok(())
    }

    pub fn get_all(&self, credential_type: Option<Secret>) -> Result<Credentials, RustbreakError> {
        let data = self.rustbreak.get_data(true)?;
        if credential_type.is_none() {
            return Ok(data);
        }
        let ctype = credential_type.unwrap();
        let mut result = Vec::new();
        for i in 0..data.data.len() {
            if std::mem::discriminant(&data.data[i].secret) == std::mem::discriminant(&ctype) {
                result.push(data.data[i].clone());
            }
        }
        Ok(Credentials {
            data: result,
        })
    }

    pub fn use_credential(&mut self, user_input: Secret) -> Result<bool, RustbreakError> {
        let mut credentials = self.rustbreak.get_data(true)?;
        match user_input {
            Secret::PinCode(pin_code) => {
                for c in &mut credentials.data {
                    if let Secret::PinCode(secret) = c.secret.clone() {
                        if self.hasher.verify(pin_code.as_bytes(), &secret) && c.check_if_useable() {
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
                        println!("{:#?}", password);
                        if self.hasher.verify(password.as_bytes(), &secret) && c.check_if_useable() {
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



#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct Credentials {
    data: Vec<Credential>,
}

impl Credentials {
    pub fn add(&mut self, credential: Credential) {
        self.data.push(credential);
    }

    pub fn remove(&mut self, uuid: Uuid) {
        for i in 0..self.data.len() {
            if self.data[i].uuid == uuid {
                self.data.remove(i);
            }
        }
    }
}