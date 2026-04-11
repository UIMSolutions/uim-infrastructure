/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.configurations;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.configuration;
import uim.platform.ai_core.domain.ports.repositories.configurations;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageConfigurationsUseCase : UIMUseCase {
  private ConfigurationRepository repo;

  this(ConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateConfigurationRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Configuration name is required");
    if (r.scenarioid.isEmpty)
      return CommandResult(false, "", "Scenario ID is required");
    if (r.executableid.isEmpty)
      return CommandResult(false, "", "Executable ID is required");
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    Configuration c;
    c.id = randomUUID();
    c.tenantId = r.tenantId;
    c.resourceGroupId = r.resourceGroupId;
    c.scenarioId = r.scenarioId;
    c.executableId = r.executableId;
    c.name = r.name;

    // Parse parameter values from key-value pairs
    ParameterValue[] params;
    foreach (pair; r.parameterValues) {
      if (pair.length >= 2) {
        ParameterValue pv;
        pv.key = pair[0];
        pv.value = pair[1];
        params ~= pv;
      }
    }
    c.parameterValues = params;

    // Parse input artifact references
    InputArtifactRef[] artifacts;
    foreach (pair; r.inputArtifacts) {
      if (pair.length >= 2) {
        InputArtifactRef ar;
        ar.key = pair[0];
        ar.artifactId = pair[1];
        artifacts ~= ar;
      }
    }
    c.inputArtifacts = artifacts;

    import core.time : MonoTime;
    c.createdAt = MonoTime.currTime.ticks;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Configuration get_(ConfigurationId id, ResourceGroupId rgId) {
    return repo.findById(id, rgId);
  }

  Configuration[] listByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    return repo.findByScenario(scenarioId, rgId);
  }

  Configuration[] list(ResourceGroupId rgId) {
    return repo.findByResourceGroup(rgId);
  }

  CommandResult remove(ConfigurationId id, ResourceGroupId rgId) {
    auto existing = repo.findById(id, rgId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Configuration not found");

    repo.remove(id, rgId);
    return CommandResult(true, id.toString, "");
  }

  size_t count(ResourceGroupId rgId) {
    return repo.countByResourceGroup(rgId);
  }
}
