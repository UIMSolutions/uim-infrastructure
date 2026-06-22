module uim.infrastructure.scim.application.dto.scim_commands;

struct CreateUserCommand {
    string externalId;
    string userName;
    string displayName;
    string givenName;
    string familyName;
    string[] emails;
}

struct ReplaceUserCommand {
    string externalId;
    string userName;
    string displayName;
    string givenName;
    string familyName;
    string[] emails;
}

struct CreateGroupCommand {
    string externalId;
    string displayName;
    string[] memberIds;
}

struct ReplaceGroupCommand {
    string externalId;
    string displayName;
    string[] memberIds;
}
