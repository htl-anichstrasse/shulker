use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use uuid::Uuid;

#[derive(Serialize, Clone, Deserialize, PartialEq, Eq, Debug)]
pub struct Credential {
    pub label: String,
    pub uuid: Uuid,
    pub start_time: DateTime<Utc>,
    pub end_time: DateTime<Utc>,
    pub uses_left: i32,
    #[serde(skip_serializing)]
    pub secret: String,
}

impl Credential {
    pub fn check_if_useable(&self) -> bool {
        let mut useable = true;
        if self.uses_left == 0 {
            useable = false;
        }
        if !self.is_now() {
            useable = false;
        }
        useable
    }

    pub fn reduce_uses(&mut self) {
        if self.uses_left > 0 {
            self.uses_left -= 1;
        }
    }

    pub fn is_now(&self) -> bool {
        let now = Utc::now();
        if self.start_time < now && self.end_time > now {
            return true;
        }
        false
    }
}
