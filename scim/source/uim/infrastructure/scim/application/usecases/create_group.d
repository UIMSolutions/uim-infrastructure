/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.application.usecases.create_group;

import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.scim.application.dto.scim_commands : CreateGroupCommand;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class CreateGroupUseCase {
    private IGroupRepository groupRepository;
    private IUserRepository userRepository;

    this(IGroupRepository groupRepository, IUserRepository userRepository) {
        this.groupRepository = groupRepository;
        this.userRepository = userRepository;
    }

    ScimGroup execute(CreateGroupCommand command) {
        if (command.displayName.length == 0) {
            throw new Exception("displayName is required");
        }
        if (groupRepository.findByDisplayName(command.displayName) !is null) {
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

        auto now = Clock.currTime();
        auto group = ScimGroup(
            randomUUID().toString(),
            command.externalId,
            command.displayName,
            command.memberIds.dup,
            now,
            now,
            "W/\"" ~ randomUUID().toString() ~ "\""
        );

        groupRepository.save(group);
        return group;
    }
}
