/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.executions;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.execution;
import uim.platform.ai_core.domain.ports.repositories.executions;

import std.algorithm : filter;
import std.array : array;

class MemoryExecutionRepository : ExecutionRepository {
  private Execution[][string] store;

  Execution findById(ExecutionId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      foreach (e; *rg) {
        if (e.id == id)
          return e;
      }
    }
    return Execution.init;
  }

  Execution[] findByConfiguration(ConfigurationId confId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.configurationId == confId).array;
    return [];
  }

  Execution[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.scenarioId == scenarioId).array;
    return [];
  }

  Execution[] findByStatus(ExecutionStatus status, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.status == status).array;
    return [];
  }

  Execution[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return [];
  }

  void save(Execution e) {
    store[e.resourceGroupId] ~= e;
  }

  void update(Execution e) {
    if (auto rg = e.resourceGroupId in store) {
      foreach (existing; *rg) {
        if (existing.id == e.id) {
          existing = e;
          return;
        }
      }
    }
  }

  void remove(ExecutionId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      *rg = (*rg).filter!(e => e.id != id).array;
    }
  }

  size_t countByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).length;
    return 0;
  }

  size_t countByStatus(ExecutionStatus status, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.status == status).array.length;
    return 0;
  }
}
