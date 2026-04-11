/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.configuration;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.configuration;

interface ConfigurationRepository {
  Configuration findById(ConfigurationId id, ResourceGroupId rgId);
  Configuration[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
  Configuration[] findByExecutable(ExecutableId execId, ResourceGroupId rgId);
  Configuration[] findByResourceGroup(ResourceGroupId rgId);
  void save(Configuration c);
  void remove(ConfigurationId id, ResourceGroupId rgId);
  size_t countByResourceGroup(ResourceGroupId rgId);
}
