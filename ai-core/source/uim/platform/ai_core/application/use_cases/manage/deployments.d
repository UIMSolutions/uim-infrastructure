/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.deployments;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.deployment;
import uim.platform.ai_core.domain.ports.repositories.deployments;
import uim.platform.ai_core.domain.ports.repositories.configurations;
import uim.platform.ai_core.domain.services.execution_scheduler;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageDeploymentsUseCase : UIMUseCase {
  private DeploymentRepository deplRepo;
  private ConfigurationRepository confRepo;

  this(DeploymentRepository deplRepo, ConfigurationRepository confRepo) {
    this.deplRepo = deplRepo;
    this.confRepo = confRepo;
  }

  CommandResult create(CreateDeploymentRequest r) {
    if (r.configurationid.isEmpty)
      return CommandResult(false, "", "Configuration ID is required");
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    auto conf = confRepo.findById(r.configurationId, r.resourceGroupId);
    if (conf.id.isEmpty)
      return CommandResult(false, "", "Configuration not found");

    Deployment d;
    d.id = randomUUID();
    d.tenantId = r.tenantId;
    d.resourceGroupId = r.resourceGroupId;
    d.configurationId = r.configurationId;
    d.scenarioId = conf.scenarioId;
    d.executableId = conf.executableId;
    d.status = DeploymentStatus.pending;
    d.statusMessage = "Deployment created and pending";
    d.ttl = r.ttl;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    d.createdAt = now;
    d.modifiedAt = now;

    deplRepo.save(d);
    return CommandResult(true, d.id, "");
  }

  CommandResult patch(PatchDeploymentRequest request) {
    if (!deplRepo.existsById(request.deploymentId, request.resourceGroupId))
      return CommandResult(false, "", "Deployment not found");

    auto d = deplRepo.findById(request.deploymentId, request.resourceGroupId);
    if (request.targetStatus.length > 0) {
      TargetStatus target;
      if (request.targetStatus == "stopped")
        target = TargetStatus.stopped;
      else if (request.targetStatus == "running")
        target = TargetStatus.running;
      else if (request.targetStatus == "deleted")
        target = TargetStatus.deleted_;
      else
        return CommandResult(false, "", "Invalid target status");

      if (!ExecutionScheduler.canTransitionDeployment(d.status, target))
        return CommandResult(false, "", "Cannot transition to target status from current status");

      d.targetStatus = target;
      if (target == TargetStatus.stopped)
        d.status = DeploymentStatus.stopped;
      else if (target == TargetStatus.running)
        d.status = DeploymentStatus.running;
      else if (target == TargetStatus.deleted_)
        d.status = DeploymentStatus.dead;
    }

    // Support configuration update for running deployments
    if (request.configurationId.length > 0)
      d.configurationId = request.configurationId;

    if (request.ttl > 0)
      d.ttl = request.ttl;

    import core.time : MonoTime;
    d.modifiedAt = MonoTime.currTime.ticks;

    deplRepo.update(d);
    return CommandResult(true, d.id, "");
  }

  Deployment get_(DeploymentId id, ResourceGroupId groupId) {
    return deplRepo.findById(id, groupId);
  }

  Deployment[] list(ResourceGroupId groupId) {
    return deplRepo.findByResourceGroup(groupId);
  }

  Deployment[] listByScenario(ScenarioId scenarioId, ResourceGroupId groupId) {
    return deplRepo.findByScenario(scenarioId, groupId);
  }

  Deployment[] listByStatus(DeploymentStatus status, ResourceGroupId groupId) {
    return deplRepo.findByStatus(status, groupId);
  }

  CommandResult remove(DeploymentId id, ResourceGroupId groupId) {
    if (!deplRepo.existsById(id, groupId))
      return CommandResult(false, "", "Deployment not found");

    deplRepo.remove(id, groupId);
    return CommandResult(true, id.toString, "");
  }

  size_t count(ResourceGroupId rgId) {
    return deplRepo.countByResourceGroup(rgId);
  }
}
