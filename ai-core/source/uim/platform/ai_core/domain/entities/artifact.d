/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.artifact;

import uim.platform.ai_core.domain.types;

struct ArtifactLabel {
  string key;
  string value;
}

struct Artifact {
  ArtifactId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutionId executionId;
  string name;
  string description;
  ArtifactKind kind;
  string url;
  ArtifactLabel[] labels;
  long createdAt;
  long modifiedAt;
}
