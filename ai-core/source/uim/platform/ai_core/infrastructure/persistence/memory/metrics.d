/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.metric;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.metric;
import uim.platform.ai_core.domain.ports.repositories.metrics;

import std.algorithm : filter;
import std.array : array;

class MemoryMetricRepository : MetricRepository {
  private Metric[] store;

  Metric findById(MetricId id, ResourceGroupId rgId) {
    foreach (m; store) {
      if (m.id == id && m.resourceGroupId == rgId)
        return m;
    }
    return Metric.init;
  }

  Metric[] findByExecution(ExecutionId execId, ResourceGroupId rgId) {
    return store.filter!(m => m.executionId == execId && m.resourceGroupId == rgId).array;
  }

  Metric[] findByResourceGroup(ResourceGroupId rgId) {
    return store.filter!(m => m.resourceGroupId == rgId).array;
  }

  void save(Metric m) {
    store ~= m;
  }

  void remove(MetricId id, ResourceGroupId rgId) {
    store = store.filter!(m => !(m.id == id && m.resourceGroupId == rgId)).array;
  }

  size_t countByExecution(ExecutionId execId, ResourceGroupId rgId) {
    return store.filter!(m => m.executionId == execId && m.resourceGroupId == rgId).array.length;
  }
}
