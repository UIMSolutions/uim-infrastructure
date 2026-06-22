module uim.infrastructure.scim.application.usecases.replace_user;

import std.datetime : Clock;
import std.string : toLower;
import std.uuid : randomUUID;
import uim.infrastructure.scim.application.dto.scim_commands : ReplaceUserCommand;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class ReplaceUserUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    ScimUser execute(string id, ReplaceUserCommand command) {
        if (command.userName.length == 0) {
            throw new Exception("userName is required");
        }

        auto existing = repository.findById(id);
        if (existing is null) {
            throw new Exception("user not found");
        }

        auto conflict = repository.findByUserName(command.userName.toLower());
        if (conflict !is null && conflict.id != id) {
            throw new Exception("userName already exists");
        }

        auto updated = ScimUser(
            id,
            command.externalId,
            command.userName,
            command.displayName,
            command.givenName,
            command.familyName,
            command.emails.dup,
            existing.createdAt,
            Clock.currTime(),
            "W/\"" ~ randomUUID().toString() ~ "\""
        );

        repository.save(updated);
        return updated;
    }
}
