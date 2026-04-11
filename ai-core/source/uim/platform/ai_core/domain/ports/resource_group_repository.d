/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.resource_groups;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.resource_group;

interface ResourceGroupRepository {
  ResourceGroup findById(ResourceGroupId id);
  ResourceGroup[] findByTenant(TenantId tenantId);
  void save(ResourceGroup rg);
  void update(ResourceGroup rg);
  void remove(ResourceGroupId id);
  size_t countByTenant(TenantId tenantId);
}
