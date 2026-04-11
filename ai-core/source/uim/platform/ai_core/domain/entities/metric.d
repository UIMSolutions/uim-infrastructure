/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.metric;

import uim.platform.ai_core.domain.types;

struct MetricLabel {
  string key;
  string value;
}

struct MetricTag {
  string key;
  string value;
}

struct MetricValue {
  string name;
  string value;
  MetricValueType type;
  long timestamp;
}

struct CustomInfo {
  string key;
  string value;
}

struct Metric {
  MetricId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ExecutionId executionId;
  MetricLabel[] labels;
  MetricTag[] tags;
  MetricValue[] metrics;
  CustomInfo[] customInfo;
  long createdAt;
}
