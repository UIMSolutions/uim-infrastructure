/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.execution;

import uim.platform.ai_core.domain.types;

struct OutputArtifactRef {
  string key;
  ArtifactId artifactId;
}

struct Execution {
  ExecutionId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  ExecutionStatus status;
  TargetStatus targetStatus;
  string statusMessage;
  OutputArtifactRef[] outputArtifacts;
  long startedAt;
  long completedAt;
  long createdAt;
  long modifiedAt;
}
