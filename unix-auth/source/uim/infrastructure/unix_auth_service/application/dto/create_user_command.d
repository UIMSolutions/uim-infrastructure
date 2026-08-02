module uim.infrastructure.unix_auth_service.application.dto.create_user_command;

struct CreateUserCommand {
    string username;
    uint uid;
    uint gid;
    string gecos;
    string homeDirectory;
    string loginShell;
    string password;
}
