/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executions;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.execution;
import uim.platform.ai_core.domain.ports.repositories.execution;
import uim.platform.ai_core.domain.ports.repositories.configuration;
import uim.platform.ai_core.domain.services.execution_scheduler;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageExecutionsUseCase : UIMUseCase {
  private ExecutionRepository execRepo;
  private ConfigurationRepository confRepo;

  this(ExecutionRepository execRepo, ConfigurationRepository confRepo) {
    this.execRepo = execRepo;
    this.confRepo = confRepo;
  }

  CommandResult create(CreateExecutionRequest r) {
    if (r.configurationid.isEmpty)
      return CommandResult(false, "", "Configuration ID is required");
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    auto conf = confRepo.findById(r.configurationId, r.resourceGroupId);
    if (conf.id.isEmpty)
      return CommandResult(false, "", "Configuration not found");

    Execution e;
    e.id = randomUUID();
    e.tenantId = r.tenantId;
    e.resourceGroupId = r.resourceGroupId;
    e.configurationId = r.configurationId;
    e.scenarioId = conf.scenarioId;
    e.executableId = conf.executableId;
    e.status = ExecutionStatus.pending;
    e.statusMessage = "Execution created and pending";

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    e.createdAt = now;
    e.modifiedAt = now;

    execRepo.save(e);
    return CommandResult(true, e.id, "");
  }

  CommandResult patch(PatchExecutionRequest r) {
    auto e = execRepo.findById(r.executionId, r.resourceGroupId);
    if (e.id.isEmpty)
      return CommandResult(false, "", "Execution not found");

    TargetStatus target;
    if (r.targetStatus == "stopped")
      target = TargetStatus.stopped;
    else if (r.targetStatus == "deleted")
      target = TargetStatus.deleted_;
    else
      return CommandResult(false, "", "Invalid target status");

    if (!ExecutionScheduler.canTransition(e.status, target))
      return CommandResult(false, "", "Cannot transition to target status from current status");

    e.targetStatus = target;
    if (target == TargetStatus.stopped)
      e.status = ExecutionStatus.stopped;
    else if (target == TargetStatus.deleted_) {
      e.status = ExecutionStatus.dead;
    }

    import core.time : MonoTime;
    e.modifiedAt = MonoTime.currTime.ticks;

    execRepo.update(e);
    return CommandResult(true, e.id, "");
  }

  Execution get_(ExecutionId id, ResourceGroupId rgId) {
    return execRepo.findById(id, rgId);
  }

  Execution[] list(ResourceGroupId rgId) {
    return execRepo.findByResourceGroup(rgId);
  }

  Execution[] listByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    return execRepo.findByScenario(scenarioId, rgId);
  }

  Execution[] listByStatus(ExecutionStatus status, ResourceGroupId rgId) {
    return execRepo.findByStatus(status, rgId);
  }

  CommandResult remove(ExecutionId id, ResourceGroupId rgId) {
    auto existing = execRepo.findById(id, rgId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Execution not found");

    execRepo.remove(id, rgId);
    return CommandResult(true, id.toString, "");
  }

  size_t count(ResourceGroupId rgId) {
    return execRepo.countByResourceGroup(rgId);
  }
}
