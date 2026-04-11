/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.artifacts;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.artifact;
import uim.platform.ai_core.domain.ports.repositories.artifacts;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageArtifactsUseCase : UIMUseCase {
  private ArtifactRepository repo;

  this(ArtifactRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateArtifactRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Artifact name is required");
    if (r.kind.length == 0)
      return CommandResult(false, "", "Artifact kind is required");
    if (r.scenarioid.isEmpty)
      return CommandResult(false, "", "Scenario ID is required");
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    Artifact a;
    a.id = randomUUID();
    a.tenantId = r.tenantId;
    a.resourceGroupId = r.resourceGroupId;
    a.scenarioId = r.scenarioId;
    a.name = r.name;
    a.description = r.description;
    a.url = r.url;

    switch (r.kind) {
    case "model":
      a.kind = ArtifactKind.model;
      break;
    case "dataset":
      a.kind = ArtifactKind.dataset;
      break;
    case "resultset":
      a.kind = ArtifactKind.resultset;
      break;
    default:
      a.kind = ArtifactKind.other;
      break;
    }

    // Parse labels
    ArtifactLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ArtifactLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    a.labels = labels;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    a.createdAt = now;
    a.modifiedAt = now;

    repo.save(a);
    return CommandResult(true, a.id, "");
  }

  Artifact get_(ArtifactId id, ResourceGroupId rgId) {
    return repo.findById(id, rgId);
  }

  Artifact[] list(ResourceGroupId rgId) {
    return repo.findByResourceGroup(rgId);
  }

  Artifact[] listByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    return repo.findByScenario(scenarioId, rgId);
  }

  Artifact[] listByKind(ArtifactKind kind, ResourceGroupId rgId) {
    return repo.findByKind(kind, rgId);
  }

  Artifact[] listByExecution(ExecutionId execId, ResourceGroupId rgId) {
    return repo.findByExecution(execId, rgId);
  }

  CommandResult remove(ArtifactId id, ResourceGroupId rgId) {
    auto existing = repo.findById(id, rgId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Artifact not found");

    repo.remove(id, rgId);
    return CommandResult(true, id.toString, "");
  }

  size_t count(ResourceGroupId rgId) {
    return repo.countByResourceGroup(rgId);
  }
}
