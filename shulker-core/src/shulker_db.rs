use rustbreak::deser::Bincode;
use rustbreak::{backend::PathBackend, Database, PathDatabase, RustbreakError};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use uuid::Uuid;

use crate::CONFIGURATION;
use crate::{
    credential_types::{Credential, Secret},
    hasher::Hasher,
};

pub struct ShulkerDB<'a> {
    rustbreak: Database<Credentials, PathBackend, Bincode>,
    hasher: Hasher<'a>,
}

impl<'a> ShulkerDB<'a> {
    pub fn new(file_path: PathBuf) -> Self {
        let path_clone = file_path.clone();
        let master = CONFIGURATION
            .read()
            .unwrap()
            .get_str("master_password")
            .unwrap();
        let rustbreak = PathDatabase::<Credentials, Bincode>::create_at_path(
            file_path,
            Credentials {
                data: Vec::new(),
                deleted: false,
                master,
            },
        )
        .unwrap_or_else(|_| panic!("Unable to create/open file at {:?}", path_clone));

        ShulkerDB {
            rustbreak,
            hasher: Hasher::new(),
        }
    }

    fn hash_secret(&mut self, secret: Secret) -> Secret {
        match secret {
            Secret::PinCode(secret_string) => {
                Secret::PinCode(self.hasher.hash(secret_string.as_bytes()))
            }
            Secret::Password(secret_string) => {
                Secret::Password(self.hasher.hash(secret_string.as_bytes()))
            }
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

    pub fn remove(&mut self, uuid: Uuid) -> Result<bool, RustbreakError> {
        self.rustbreak.load()?;
        self.rustbreak.write_safe(move |db| {
            db.remove(uuid);
        })?;
        self.rustbreak.save()?;
        let deleted;
        {
            deleted = self.rustbreak.borrow_data().unwrap().deleted;
        }
        Ok(deleted)
    }

    pub fn get_all(
        &self,
        credential_type: Option<Secret>,
    ) -> Result<Vec<Credential>, RustbreakError> {
        let data = self.rustbreak.get_data(true)?;
        if credential_type.is_none() {
            return Ok(data.data);
        }
        let ctype = credential_type.unwrap();
        let mut result = Vec::new();
        for i in 0..data.data.len() {
            if std::mem::discriminant(&data.data[i].secret) == std::mem::discriminant(&ctype) {
                result.push(data.data[i].clone());
            }
        }
        Ok(result)
    }

    pub fn use_credential(&mut self, user_input: Secret) -> Result<bool, RustbreakError> {
        let mut credentials = self.rustbreak.get_data(true)?;
        match user_input {
            Secret::PinCode(pin_code) => {
                for c in &mut credentials.data {
                    if let Secret::PinCode(secret) = c.secret.clone() {
                        if self.hasher.verify(pin_code.as_bytes(), &secret) && c.check_if_useable()
                        {
                            c.reduce_uses();
                            self.rustbreak.put_data(credentials, true)?;
                            return Ok(true);
                        }
                    }
                }
            }
            Secret::Password(password) => {
                for c in &mut credentials.data {
                    if let Secret::Password(secret) = c.secret.clone() {
                        if self.hasher.verify(password.as_bytes(), &secret) && c.check_if_useable()
                        {
                            c.reduce_uses();
                            self.rustbreak.put_data(credentials, true)?;
                            return Ok(true);
                        }
                    }
                }
            }
        }
        Ok(false)
    }

    pub fn use_master(&self, secret: String) -> bool {
        if secret == self.rustbreak.get_data(false).unwrap().master {
            return true;
        }
        false
    }
}

#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct Credentials {
    pub data: Vec<Credential>,
    pub deleted: bool,
    pub master: String,
}

impl Credentials {
    pub fn add(&mut self, credential: Credential) {
        self.data.push(credential);
    }

    pub fn remove(&mut self, uuid: Uuid) -> bool {
        for i in 0..self.data.len() {
            if self.data[i].uuid == uuid {
                self.data.remove(i);
                return true;
            }
        }
        false
    }
}
