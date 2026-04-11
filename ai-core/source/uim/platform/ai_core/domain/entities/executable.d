/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.executable;

import uim.platform.ai_core.domain.types;

struct InputArtifactBinding {
  string key;
  ArtifactKind kind;
  string description;
}

struct OutputArtifactBinding {
  string key;
  ArtifactKind kind;
  string description;
}

struct ParameterBinding {
  string key;
  string type;
  string default_;
  string description;
}

struct Executable {
  ExecutableId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  string name;
  string description;
  ExecutableType type;
  string versionId;
  InputArtifactBinding[] inputArtifacts;
  OutputArtifactBinding[] outputArtifacts;
  ParameterBinding[] parameters;
  string[] labels;
  string deployable;
  long createdAt;
  long modifiedAt;
}
