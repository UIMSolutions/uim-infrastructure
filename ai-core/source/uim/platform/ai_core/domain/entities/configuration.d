/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.configuration;

import uim.platform.ai_core.domain.types;

struct ParameterValue {
  string key;
  string value;
}

struct InputArtifactRef {
  string key;
  ArtifactId artifactId;
}

struct Configuration {
  ConfigurationId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  string name;
  ParameterValue[] parameterValues;
  InputArtifactRef[] inputArtifacts;
  long createdAt;
}
