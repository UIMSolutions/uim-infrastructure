/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.metrics;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.metric;

interface MetricRepository {
  Metric findById(MetricId id, ResourceGroupId rgId);
  Metric[] findByExecution(ExecutionId execId, ResourceGroupId rgId);
  Metric[] findByResourceGroup(ResourceGroupId rgId);
  void save(Metric m);
  void remove(MetricId id, ResourceGroupId rgId);
  size_t countByExecution(ExecutionId execId, ResourceGroupId rgId);
}
