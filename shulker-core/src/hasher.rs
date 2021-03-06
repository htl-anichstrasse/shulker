use argon2::{
    password_hash::SaltString, Argon2, ParamsBuilder, PasswordHash, PasswordHasher,
    PasswordVerifier,
};
use rand_core::OsRng;

pub struct Hasher<'a> {
    argon2: Argon2<'a>,
}

impl<'a> Hasher<'a> {
    pub fn new() -> Self {
        let m_cost = crate::CONFIGURATION
            .read()
            .unwrap()
            .get_int("hash_memory_size")
            .unwrap() as u32;
        let t_cost = crate::CONFIGURATION
            .read()
            .unwrap()
            .get_int("hash_iterations")
            .unwrap() as u32;
        let p_cost = crate::CONFIGURATION
            .read()
            .unwrap()
            .get_int("hash_parallelism")
            .unwrap() as u32;
        let params = ParamsBuilder::default()
            .m_cost(m_cost)
            .unwrap()
            .t_cost(t_cost)
            .unwrap()
            .p_cost(p_cost)
            .unwrap()
            .clone()
            .params()
            .unwrap();

        Hasher {
            argon2: Argon2::new(argon2::Algorithm::Argon2id, argon2::Version::V0x13, params),
        }
    }

    pub fn hash(&self, secret: &[u8]) -> String {
        let salt = SaltString::generate(&mut OsRng);
        self.argon2
            .hash_password(secret, &salt)
            .unwrap()
            .to_string()
    }

    pub fn verify(&self, secret: &[u8], hash: &str) -> bool {
        self.argon2
            .verify_password(secret, &PasswordHash::new(hash).unwrap())
            .is_ok()
    }
}
