/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.deployments;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.deployment;

interface DeploymentRepository {
  Deployment findById(DeploymentId id, ResourceGroupId rgId);
  Deployment[] findByConfiguration(ConfigurationId confId, ResourceGroupId rgId);
  Deployment[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
  Deployment[] findByStatus(DeploymentStatus status, ResourceGroupId rgId);
  Deployment[] findByResourceGroup(ResourceGroupId rgId);
  void save(Deployment d);
  void update(Deployment d);
  void remove(DeploymentId id, ResourceGroupId rgId);
  size_t countByResourceGroup(ResourceGroupId rgId);
  size_t countByStatus(DeploymentStatus status, ResourceGroupId rgId);
}
