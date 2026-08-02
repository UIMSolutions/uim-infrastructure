module uim.infrastructure.hts_service.domain.entities.unix_user;

struct PasswdEntry {
    string username;
    string passwordPlaceholder;
    uint uid;
    uint gid;
    string gecos;
    string homeDirectory;
    string loginShell;
}

struct ShadowEntry {
    string username;
    string passwordHash;
    long lastChangeDay;
    long minDays;
    long maxDays;
    long warnDays;
    long inactiveDays;
    long expireDay;
    string reserved;

    bool locked() const {
        return passwordHash.length > 0 && (passwordHash[0] == '!' || passwordHash[0] == '*');
    }
}

struct UnixUser {
    PasswdEntry passwd;
    ShadowEntry shadow;
    bool hasShadow;
}

struct MaybeUnixUser {
    bool found;
    UnixUser value;
}
