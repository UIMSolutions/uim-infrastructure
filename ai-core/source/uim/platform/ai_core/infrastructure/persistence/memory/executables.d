/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.executable;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.executable;
import uim.platform.ai_core.domain.ports.repositories.executables;

import std.algorithm : filter;
import std.array : array;

class MemoryExecutableRepository : ExecutableRepository {
  private Executable[][string] store;

  Executable findById(ExecutableId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      foreach (e; *rg) {
        if (e.id == id)
          return e;
      }
    }
    return Executable.init;
  }

  Executable[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.scenarioId == scenarioId).array;
    return [];
  }

  Executable[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return [];
  }

  void save(Executable e) {
    store[e.resourceGroupId] ~= e;
  }

  void update(Executable e) {
    if (auto rg = e.resourceGroupId in store) {
      foreach (existing; *rg) {
        if (existing.id == e.id) {
          existing = e;
          return;
        }
      }
    }
  }

  void remove(ExecutableId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      *rg = (*rg).filter!(e => e.id != id).array;
    }
  }

  size_t countByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(e => e.scenarioId == scenarioId).array.length;
    return 0;
  }
}
