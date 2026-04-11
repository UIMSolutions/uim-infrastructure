/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.configurations;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.configuration;
import uim.platform.ai_core.domain.ports.repositories.configurations;

import std.algorithm : filter;
import std.array : array;

class MemoryConfigurationRepository : ConfigurationRepository {
  private Configuration[][string] store;

  Configuration findById(ConfigurationId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      foreach (c; *rg) {
        if (c.id == id)
          return c;
      }
    }
    return Configuration.init;
  }

  Configuration[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(c => c.scenarioId == scenarioId).array;
    return [];
  }

  Configuration[] findByExecutable(ExecutableId execId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(c => c.executableId == execId).array;
    return [];
  }

  Configuration[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return [];
  }

  void save(Configuration c) {
    store[c.resourceGroupId] ~= c;
  }

  void remove(ConfigurationId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      *rg = (*rg).filter!(c => c.id != id).array;
    }
  }

  size_t countByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).length;
    return 0;
  }
}
