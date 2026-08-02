module uim.infrastructure.hts_service.application.dto.unix_auth_commands;

struct CreateUserCommand {
    string username;
    uint uid;
    uint gid;
    string gecos;
    string homeDirectory;
    string loginShell;
    string password;
}

struct SetPasswordCommand {
    string username;
    string password;
    string algorithm;
}

struct GenerateHashCommand {
    string password;
    string algorithm;
    string salt;
}

struct VerifyPasswordCommand {
    string password;
    string existingHash;
}
