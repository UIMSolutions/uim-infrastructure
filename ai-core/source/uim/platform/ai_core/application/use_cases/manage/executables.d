/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executables;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.executable;
import uim.platform.ai_core.domain.ports.repositories.executables;
import uim.platform.ai_core.application.dto;

class ManageExecutablesUseCase : UIMUseCase {
    private ExecutableRepository repo;

    this(ExecutableRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateExecutableRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Executable ID is required");
        if (r.scenarioid.isEmpty)
            return CommandResult(false, "", "Scenario ID is required");
        if (r.resourceGroupid.isEmpty)
            return CommandResult(false, "", "Resource group ID is required");

        auto existing = repo.findById(r.id, r.resourceGroupId);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Executable already exists");

        Executable e;
        e.id = r.id;
        e.tenantId = r.tenantId;
        e.resourceGroupId = r.resourceGroupId;
        e.scenarioId = r.scenarioId;
        e.name = r.name;
        e.description = r.description;
        e.versionId = r.versionId;
        e.deployable = r.deployable;

        if (r.type == "serving")
            e.type = ExecutableType.serving;
        else
            e.type = ExecutableType.workflow;

        import core.time : MonoTime;

        auto now = MonoTime.currTime.ticks;
        e.createdAt = now;
        e.modifiedAt = now;

        repo.save(e);
        return CommandResult(true, e.id, "");
    }

    Executable get_(ExecutableId id, ResourceGroupId rgId) {
        return repo.findById(id, rgId);
    }

    Executable[] listByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
        return repo.findByScenario(scenarioId, rgId);
    }

    Executable[] list(ResourceGroupId rgId) {
        return repo.findByResourceGroup(rgId);
    }

    CommandResult remove(ExecutableId id, ResourceGroupId rgId) {
        auto existing = repo.findById(id, rgId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Executable not found");

        repo.remove(id, rgId);
        return CommandResult(true, id.toString, "");
    }
}
