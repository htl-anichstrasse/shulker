use std::time::{SystemTime};
use serde::{Serialize, Deserialize};
use uuid::Uuid;


pub enum UserInput {
    PinCode(String),
    Password(String),
}
#[derive(Serialize, Clone, Deserialize, PartialEq, Eq)]
pub struct Credential {
    pub uuid: Uuid,
    pub time_frame: Option<TimeFrame>,
    pub uses_left: Option<u32>,
    pub secret: Secret,
}

impl Credential {
    pub fn check_if_useable(&self) -> bool {
        let mut useable = true;
        if self.uses_left.is_some() {
            if self.uses_left.unwrap() == 0 {
                useable = false;
            }
        }
        if self.time_frame.is_some() {
            if !self.time_frame.as_ref().unwrap().is_now() {
                useable = false;
            }
        }
        useable
    }

    pub fn reduce_uses(&mut self) {
        if self.uses_left.is_some() {
            let uses = self.uses_left.unwrap();
            if uses > 0 {
                self.uses_left = Some(uses - 1);
            }
        }
    }
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq)]
pub enum Secret {
    PinCode(String),
    Password(String),
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq)]
pub struct TimeFrame {
    pub start_time: SystemTime,
    pub end_time: SystemTime,
}

impl TimeFrame {
    pub fn is_now(&self) -> bool {
        let now = SystemTime::now();
        if self.start_time < now && self.end_time > now {
            return true;
        }
        false
    }
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq)]
pub struct PinCodeData {
    pub data: String,
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq)]
pub struct PasswordData {
    pub data: String,
}