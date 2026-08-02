module uim.infrastructure.hts_service.infrastructure.security.crypt_password_crypto;

import uim.infrastructure.hts_service.domain.ports.security.password_crypto :
    IPasswordCrypto;
import std.array : appender;
import std.exception : collectException;
import std.string : fromStringz, toLower, toStringz;
import core.stdc.stdlib : rand;
import core.stdc.string : strcmp;

extern (C) char* crypt(const(char)* key, const(char)* salt);
extern (C) int getentropy(void* buffer, size_t length);

class CryptPasswordCrypto : IPasswordCrypto {
    private enum string SALT_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789./";

    override string createSalt(string algorithm, uint length = 16) {
        auto prefix = saltPrefix(algorithm);
        auto randomPart = randomSaltPart(length);
        return prefix ~ randomPart ~ "$";
    }

    override string hashPassword(string password, string saltSpec) {
        auto cHash = crypt(toStringz(password), toStringz(saltSpec));
        if (cHash is null) {
            throw new Exception("crypt failed to generate hash");
        }

        return fromStringz(cHash).idup;
    }

    override bool verifyPassword(string password, string existingHash) {
        auto cHash = crypt(toStringz(password), toStringz(existingHash));
        if (cHash is null) {
            return false;
        }

        return strcmp(cHash, toStringz(existingHash)) == 0;
    }

    private string saltPrefix(string algorithm) {
        auto a = algorithm.toLower();
        switch (a) {
            case "sha512":
                return "$6$";
            case "sha256":
                return "$5$";
            case "md5":
                return "$1$";
            default:
                throw new Exception("unsupported algorithm: " ~ algorithm ~ ". allowed: sha512, sha256, md5");
        }
    }

    private string randomSaltPart(uint length) {
        if (length == 0) {
            throw new Exception("salt length must be > 0");
        }

        ubyte[] bytes;
        bytes.length = length;

        auto entropyError = collectException(getentropy(bytes.ptr, bytes.length));
        if (entropyError !is null) {
            foreach (i; 0 .. length) {
                bytes[i] = cast(ubyte) rand();
            }
        }

        auto buffer = appender!string();
        foreach (b; bytes) {
            auto idx = b % cast(ubyte) SALT_ALPHABET.length;
            buffer.put(SALT_ALPHABET[idx]);
        }

        return buffer.data;
    }
}
