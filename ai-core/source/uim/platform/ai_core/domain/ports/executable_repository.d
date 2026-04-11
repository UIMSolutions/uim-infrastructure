/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.executables;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.executable;

interface ExecutableRepository {
  Executable findById(ExecutableId id, ResourceGroupId rgId);
  Executable[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
  Executable[] findByResourceGroup(ResourceGroupId rgId);
  void save(Executable e);
  void update(Executable e);
  void remove(ExecutableId id, ResourceGroupId rgId);
  size_t countByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
}
