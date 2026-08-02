module uim.infrastructure.hts_service.infrastructure.persistence.files.unix_auth_repository;

import uim.infrastructure.hts_service.domain.entities.unix_user : MaybeUnixUser,
    PasswdEntry, ShadowEntry, UnixUser;
import uim.infrastructure.hts_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;
import std.array : join, split;
import std.conv : to;
import std.exception : collectException;
import std.file : exists, readText, remove, rename, write;
import std.string : splitLines, strip;

class FileUnixAuthRepository : IUnixAuthRepository {
    private string passwdPath;
    private string shadowPath;

    this(string passwdPath, string shadowPath) {
        this.passwdPath = passwdPath;
        this.shadowPath = shadowPath;
    }

    override UnixUser[] listUsers() {
        auto passwdEntries = readPasswd();
        auto shadowEntries = readShadow();

        UnixUser[] users;
        foreach (entry; passwdEntries) {
            auto maybeShadow = findShadow(shadowEntries, entry.username);
            users ~= UnixUser(entry, maybeShadow.value, maybeShadow.found);
        }

        return users;
    }

    override MaybeUnixUser getUser(string username) {
        auto passwdEntries = readPasswd();
        auto shadowEntries = readShadow();

        foreach (entry; passwdEntries) {
            if (entry.username == username) {
                auto maybeShadow = findShadow(shadowEntries, username);
                return MaybeUnixUser(true, UnixUser(entry, maybeShadow.value, maybeShadow.found));
            }
        }

        return MaybeUnixUser(false, UnixUser.init);
    }

    override UnixUser createUser(PasswdEntry passwdEntry, ShadowEntry shadowEntry) {
        auto passwdEntries = readPasswd();
        auto shadowEntries = readShadow();

        foreach (entry; passwdEntries) {
            if (entry.username == passwdEntry.username) {
                throw new Exception("user already exists: " ~ passwdEntry.username);
            }
            if (entry.uid == passwdEntry.uid) {
                throw new Exception("uid already exists: " ~ to!string(passwdEntry.uid));
            }
        }

        passwdEntries ~= passwdEntry;
        shadowEntries ~= shadowEntry;

        writePasswd(passwdEntries);
        writeShadow(shadowEntries);

        return UnixUser(passwdEntry, shadowEntry, true);
    }

    override UnixUser setPasswordHash(string username, string passwordHash, long lastChangeDay) {
        auto passwdEntries = readPasswd();
        auto shadowEntries = readShadow();

        PasswdEntry targetPasswd;
        bool foundPasswd;
        foreach (entry; passwdEntries) {
            if (entry.username == username) {
                targetPasswd = entry;
                foundPasswd = true;
                break;
            }
        }

        if (!foundPasswd) {
            throw new Exception("user not found in passwd: " ~ username);
        }

        bool foundShadow;
        foreach (i, ref entry; shadowEntries) {
            if (entry.username == username) {
                entry.passwordHash = passwordHash;
                entry.lastChangeDay = lastChangeDay;
                foundShadow = true;
                break;
            }
        }

        if (!foundShadow) {
            shadowEntries ~= ShadowEntry(username, passwordHash, lastChangeDay, 0, 99_999, 7, -1, -1, "");
        }

        writeShadow(shadowEntries);

        auto maybeShadow = findShadow(shadowEntries, username);
        return UnixUser(targetPasswd, maybeShadow.value, maybeShadow.found);
    }

    private PasswdEntry[] readPasswd() {
        if (!exists(passwdPath)) {
            throw new Exception("passwd file not found: " ~ passwdPath);
        }

        PasswdEntry[] entries;
        foreach (line; readText(passwdPath).splitLines()) {
            auto clean = line.strip();
            if (clean.length == 0 || clean[0] == '#') {
                continue;
            }
            entries ~= parsePasswdLine(clean);
        }

        return entries;
    }

    private ShadowEntry[] readShadow() {
        if (!exists(shadowPath)) {
            throw new Exception("shadow file not found: " ~ shadowPath);
        }

        ShadowEntry[] entries;
        foreach (line; readText(shadowPath).splitLines()) {
            auto clean = line.strip();
            if (clean.length == 0 || clean[0] == '#') {
                continue;
            }
            entries ~= parseShadowLine(clean);
        }

        return entries;
    }

    private PasswdEntry parsePasswdLine(string line) {
        auto parts = line.split(":");
        if (parts.length != 7) {
            throw new Exception("invalid passwd line format");
        }

        return PasswdEntry(
            parts[0].idup,
            parts[1].idup,
            toUInt(parts[2]),
            toUInt(parts[3]),
            parts[4].idup,
            parts[5].idup,
            parts[6].idup
        );
    }

    private ShadowEntry parseShadowLine(string line) {
        auto parts = line.split(":");
        if (parts.length < 2) {
            throw new Exception("invalid shadow line format");
        }

        while (parts.length < 9) {
            parts ~= "";
        }

        return ShadowEntry(
            parts[0].idup,
            parts[1].idup,
            toLong(parts[2], -1),
            toLong(parts[3], -1),
            toLong(parts[4], -1),
            toLong(parts[5], -1),
            toLong(parts[6], -1),
            toLong(parts[7], -1),
            parts[8].idup
        );
    }

    private void writePasswd(PasswdEntry[] entries) {
        string[] lines;
        foreach (entry; entries) {
            lines ~= toPasswdLine(entry);
        }

        atomicWrite(passwdPath, join(lines, "\n") ~ "\n");
    }

    private void writeShadow(ShadowEntry[] entries) {
        string[] lines;
        foreach (entry; entries) {
            lines ~= toShadowLine(entry);
        }

        atomicWrite(shadowPath, join(lines, "\n") ~ "\n");
    }

    private void atomicWrite(string path, string content) {
        auto tempPath = path ~ ".tmp";
        write(tempPath, content);

        if (exists(path)) {
            remove(path);
        }
        rename(tempPath, path);
    }

    private string toPasswdLine(PasswdEntry entry) {
        return entry.username ~ ":" ~ entry.passwordPlaceholder ~ ":" ~ to!string(entry.uid)
            ~ ":" ~ to!string(entry.gid) ~ ":" ~ entry.gecos ~ ":"
            ~ entry.homeDirectory ~ ":" ~ entry.loginShell;
    }

    private string toShadowLine(ShadowEntry entry) {
        return entry.username ~ ":" ~ entry.passwordHash ~ ":" ~ formatShadowNumber(entry.lastChangeDay)
            ~ ":" ~ formatShadowNumber(entry.minDays) ~ ":" ~ formatShadowNumber(entry.maxDays)
            ~ ":" ~ formatShadowNumber(entry.warnDays) ~ ":" ~ formatShadowNumber(entry.inactiveDays)
            ~ ":" ~ formatShadowNumber(entry.expireDay) ~ ":" ~ entry.reserved;
    }

    private string formatShadowNumber(long value) {
        return value < 0 ? "" : to!string(value);
    }

    private uint toUInt(string value) {
        uint parsed;
        auto err = collectException(parsed = value.to!uint);
        if (err !is null) {
            throw new Exception("invalid unsigned integer value: " ~ value);
        }
        return parsed;
    }

    private long toLong(string value, long fallback) {
        if (value.length == 0) {
            return fallback;
        }

        long parsed;
        auto err = collectException(parsed = value.to!long);
        return err is null ? parsed : fallback;
    }

    private MaybeShadow findShadow(ShadowEntry[] entries, string username) {
        foreach (entry; entries) {
            if (entry.username == username) {
                return MaybeShadow(true, entry);
            }
        }
        return MaybeShadow(false, ShadowEntry.init);
    }

    private struct MaybeShadow {
        bool found;
        ShadowEntry value;
    }
}
