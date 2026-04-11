/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.scenarios;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.scenario;
import uim.platform.ai_core.domain.ports.repositories.scenarios;

import std.algorithm : filter;
import std.array : array;

class MemoryScenarioRepository : ScenarioRepository {
  private Scenario[][string] store; // key: rgId

  Scenario findById(ScenarioId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      foreach (s; *rg) {
        if (s.id == id)
          return s;
      }
    }
    return Scenario.init;
  }

  Scenario[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return [];
  }

  Scenario[] findByTenant(TenantId tenantId) {
    Scenario[] result;
    foreach (rg; store.byValue) {
      foreach (s; rg) {
        if (s.tenantId == tenantId)
          result ~= s;
      }
    }
    return result;
  }

  void save(Scenario s) {
    store[s.resourceGroupId] ~= s;
  }

  void update(Scenario s) {
    if (auto rg = s.resourceGroupId in store) {
      foreach (existing; *rg) {
        if (existing.id == s.id) {
          existing = s;
          return;
        }
      }
    }
  }

  void remove(ScenarioId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      *rg = (*rg).filter!(s => s.id != id).array;
    }
  }

  size_t countByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).length;
    return 0;
  }
}
