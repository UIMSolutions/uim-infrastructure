module uim.infrastructure.scim.application.usecases.create_user;

import std.datetime : Clock;
import std.string : toLower;
import std.uuid : randomUUID;
import uim.infrastructure.scim.application.dto.scim_commands : CreateUserCommand;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class CreateUserUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    ScimUser execute(CreateUserCommand command) {
        if (command.userName.length == 0) {
            throw new Exception("userName is required");
        }
        if (repository.findByUserName(command.userName.toLower()) !is null) {
            throw new Exception("userName already exists");
        }

        auto now = Clock.currTime();
        auto user = ScimUser(
            randomUUID().toString(),
            command.externalId,
            command.userName,
            command.displayName,
            command.givenName,
            command.familyName,
            command.emails.dup,
            now,
            now,
            "W/\"" ~ randomUUID().toString() ~ "\""
        );
        repository.save(user);
        return user;
    }
}
