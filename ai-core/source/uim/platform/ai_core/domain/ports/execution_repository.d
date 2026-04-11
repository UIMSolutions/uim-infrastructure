/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.executions;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.execution;

interface ExecutionRepository {
  Execution findById(ExecutionId id, ResourceGroupId rgId);
  Execution[] findByConfiguration(ConfigurationId confId, ResourceGroupId rgId);
  Execution[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
  Execution[] findByStatus(ExecutionStatus status, ResourceGroupId rgId);
  Execution[] findByResourceGroup(ResourceGroupId rgId);
  void save(Execution e);
  void update(Execution e);
  void remove(ExecutionId id, ResourceGroupId rgId);
  size_t countByResourceGroup(ResourceGroupId rgId);
  size_t countByStatus(ExecutionStatus status, ResourceGroupId rgId);
}
