use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use uuid::Uuid;

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq, Debug)]
pub struct Credential {
    pub label: String,
    pub uuid: Uuid,
    pub time_frame: Option<TimeFrame>,
    pub uses_left: Option<u32>,
    pub secret: Secret,
}

impl Credential {
    pub fn check_if_useable(&self) -> bool {
        let mut useable = true;
        if self.uses_left.is_some() && self.uses_left.unwrap() == 0 {
            useable = false;
        }
        if self.time_frame.is_some() && !self.time_frame.as_ref().unwrap().is_now() {
            useable = false;
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

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq, Debug)]
pub enum Secret {
    PinCode(String),
    Password(String),
}

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq, Debug)]
pub struct TimeFrame {
    pub start_time: DateTime<Utc>,
    pub end_time: DateTime<Utc>,
}

impl TimeFrame {
    pub fn is_now(&self) -> bool {
        let now = Utc::now();
        if self.start_time < now && self.end_time > now {
            return true;
        }
        false
    }
}
