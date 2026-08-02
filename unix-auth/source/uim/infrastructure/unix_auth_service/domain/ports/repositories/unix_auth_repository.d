module uim.infrastructure.unix_auth_service.domain.ports.repositories.unix_auth_repository;

import uim.infrastructure.unix_auth_service.domain.entities.unix_user : MaybeUnixUser,
    PasswdEntry, ShadowEntry, UnixUser;

interface IUnixAuthRepository {
    UnixUser[] listUsers();
    MaybeUnixUser getUser(string username);
    UnixUser createUser(PasswdEntry passwdEntry, ShadowEntry shadowEntry);
    UnixUser setPasswordHash(string username, string passwordHash, long lastChangeDay);
}
