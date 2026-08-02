module uim.infrastructure.unix_auth_service.application.dto.password_command;

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
