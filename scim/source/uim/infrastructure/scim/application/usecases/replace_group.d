module uim.infrastructure.scim.application.usecases.replace_group;

import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.scim.application.dto.scim_commands : ReplaceGroupCommand;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class ReplaceGroupUseCase {
    private IGroupRepository groupRepository;
    private IUserRepository userRepository;

    this(IGroupRepository groupRepository, IUserRepository userRepository) {
        this.groupRepository = groupRepository;
        this.userRepository = userRepository;
    }

    ScimGroup execute(string id, ReplaceGroupCommand command) {
        if (command.displayName.length == 0) {
            throw new Exception("displayName is required");
        }

        auto existing = groupRepository.findById(id);
        if (existing is null) {
            throw new Exception("group not found");
        }

        auto conflict = groupRepository.findByDisplayName(command.displayName);
        if (conflict !is null && conflict.id != id) {
            throw new Exception("displayName already exists");
        }

        foreach (memberId; command.memberIds) {
            if (memberId.length == 0) {
                continue;
            }
            if (userRepository.findById(memberId) is null) {
                throw new Exception("group member not found: " ~ memberId);
            }
        }

        auto updated = ScimGroup(
            id,
            command.externalId,
            command.displayName,
            command.memberIds.dup,
            existing.createdAt,
            Clock.currTime(),
            "W/\"" ~ randomUUID().toString() ~ "\""
        );

        groupRepository.save(updated);
        return updated;
    }
}
