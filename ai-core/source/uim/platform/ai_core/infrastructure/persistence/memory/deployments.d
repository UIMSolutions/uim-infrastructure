/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.deployment;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.deployment;
import uim.platform.ai_core.domain.ports.repositories.deployments;

import std.algorithm : filter;
import std.array : array;

class MemoryDeploymentRepository : DeploymentRepository {
  private Deployment[][string] store;

  Deployment findById(DeploymentId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      foreach (d; *rg) {
        if (d.id == id)
          return d;
      }
    }
    return Deployment.init;
  }

  Deployment[] findByConfiguration(ConfigurationId confId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(d => d.configurationId == confId).array;
    return [];
  }

  Deployment[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(d => d.scenarioId == scenarioId).array;
    return [];
  }

  Deployment[] findByStatus(DeploymentStatus status, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(d => d.status == status).array;
    return [];
  }

  Deployment[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return [];
  }

  void save(Deployment d) {
    store[d.resourceGroupId] ~= d;
  }

  void update(Deployment d) {
    if (auto rg = d.resourceGroupId in store) {
      foreach (existing; *rg) {
        if (existing.id == d.id) {
          existing = d;
          return;
        }
      }
    }
  }

  void remove(DeploymentId id, ResourceGroupId rgId) {
    if (auto rg = rgId in store) {
      *rg = (*rg).filter!(d => d.id != id).array;
    }
  }

  size_t countByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).length;
    return 0;
  }

  size_t countByStatus(DeploymentStatus status, ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return (*rg).filter!(d => d.status == status).array.length;
    return 0;
  }
}
