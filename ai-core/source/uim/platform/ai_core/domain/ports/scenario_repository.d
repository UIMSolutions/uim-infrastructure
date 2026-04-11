/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.scenarios;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.scenario;

interface ScenarioRepository {
  Scenario findById(ScenarioId id, ResourceGroupId rgId);
  Scenario[] findByResourceGroup(ResourceGroupId rgId);
  Scenario[] findByTenant(TenantId tenantId);
  void save(Scenario s);
  void update(Scenario s);
  void remove(ScenarioId id, ResourceGroupId rgId);
  size_t countByResourceGroup(ResourceGroupId rgId);
}
