/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.resource_group;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.resource_group;
import uim.platform.ai_core.domain.ports.repositories.resource_groups;

import std.algorithm : filter;
import std.array : array;

class MemoryResourceGroupRepository : ResourceGroupRepository {
  private ResourceGroup[ResourceGroupId] store;

  ResourceGroup findById(ResourceGroupId id) {
    if (auto p = id in store)
      return *p;
    return ResourceGroup.init;
  }

  ResourceGroup[] findByTenant(TenantId tenantId) {
    return store.values.filter!(rg => rg.tenantId == tenantId).array;
  }

  void save(ResourceGroup rg) {
    store[rg.id] = rg;
  }

  void update(ResourceGroup rg) {
    store[rg.id] = rg;
  }

  void remove(ResourceGroupId id) {
    store.remove(id);
  }

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(rg => rg.tenantId == tenantId).array.length;
  }
}
