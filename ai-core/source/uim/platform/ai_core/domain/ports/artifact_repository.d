/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.artifacts;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.artifact;

interface ArtifactRepository {
  Artifact findById(ArtifactId id, ResourceGroupId rgId);
  Artifact[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId);
  Artifact[] findByExecution(ExecutionId execId, ResourceGroupId rgId);
  Artifact[] findByKind(ArtifactKind kind, ResourceGroupId rgId);
  Artifact[] findByResourceGroup(ResourceGroupId rgId);
  void save(Artifact a);
  void update(Artifact a);
  void remove(ArtifactId id, ResourceGroupId rgId);
  size_t countByResourceGroup(ResourceGroupId rgId);
}
