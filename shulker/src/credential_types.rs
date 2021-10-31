use std::{convert::TryFrom};


// PinCode:
// A PinCode is a password only containing digits (0-9)
#[derive(Debug, PartialEq)]
struct PinCode(String);

impl TryFrom<&str> for PinCode {
    type Error = PinConversionError;
    fn try_from(code: &str) -> Result<PinCode, PinConversionError> {
        // Pincode needs to be numeric
        for c in code.chars() {
            if !c.is_numeric() {
                return Err(PinConversionError::IsNotNumeric)
            }
        }

        // Pincode needs to be at least 1 char
        if code.len() == 0 {
            return Err(PinConversionError::TooShort)
        }

        return Ok(PinCode(String::from(code)))
    }
}

#[derive(Debug, PartialEq, Eq)]
enum PinConversionError {
    IsNotNumeric,
    TooShort,
}



#[derive(Debug, PartialEq, Eq)]
struct Password(String);

impl TryFrom<&str> for Password {
    type Error = PasswordConversionError;
    fn try_from(code: &str) -> Result<Password, PasswordConversionError> {

        // Password needs to be at least 1 char
        if code.len() == 0 {
            return Err(PasswordConversionError::TooShort)
        }

        return Ok(Password(String::from(code)))
    }
}

#[derive(Debug, PartialEq, Eq)]
enum PasswordConversionError {
    TooShort,
}




#[cfg(test)]
mod tests {
    use std::convert::TryFrom;

    use crate::credential_types::{Password, PasswordConversionError, PinCode, PinConversionError};

    #[test]
    fn pincode_tryfrom_string() {
        let pin_code0 = String::from("61230");
        let pin_code1 = String::from("");
        let pin_code2 = String::from("412F23482341BXa++-*");

        let pin0 = PinCode::try_from(pin_code0.as_str());
        let pin1 = PinCode::try_from(pin_code1.as_str());
        let pin2 = PinCode::try_from(pin_code2.as_str());

        assert!(pin0.is_ok());
        assert_eq!(pin0.unwrap().0, "61230");
        assert_eq!(pin1, Err(PinConversionError::TooShort));
        assert_eq!(pin2, Err(PinConversionError::IsNotNumeric));
    }

    #[test]
    fn password_tryfrom_string() {
        let pw_code0 = String::from("Alexander334");
        let pw_code1 = String::from("");
        let pw_code2 = String::from("412F23482341BXa++-*");

        let pw0 = Password::try_from(pw_code0.as_str());
        let pw1 = Password::try_from(pw_code1.as_str());
        let pw2 = Password::try_from(pw_code2.as_str());

        assert!(pw0.is_ok());
        assert_eq!(pw0.unwrap().0, "Alexander334");
        assert_eq!(pw1, Err(PasswordConversionError::TooShort));
        assert!(pw2.is_ok());
    }
}
