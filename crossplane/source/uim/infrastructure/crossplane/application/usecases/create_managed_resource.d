/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.application.usecases.create_managed_resource;

import uim.infrastructure.crossplane.application.dto.commands : CreateManagedResourceCommand;
import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource, ResourceStatus, ReadyCondition;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;
import std.datetime.systime : Clock;

class CreateManagedResourceUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    ManagedResource execute(CreateManagedResourceCommand cmd) {
        auto now = Clock.currTime.toISOExtString;
        auto resource = ManagedResource(
            generateId(),
            cmd.name,
            cmd.providerId,
            cmd.apiGroup,
            cmd.kind,
            cmd.spec.dup,
            null,
            ResourceStatus.CREATING,
            ReadyCondition.FALSE,
            "",
            "",
            now,
            now
        );
        repo.save(resource);
        return resource;
    }

    private string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }
}
