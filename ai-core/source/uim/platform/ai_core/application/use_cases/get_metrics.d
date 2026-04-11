/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.get_metrics;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.metric;
import uim.platform.ai_core.domain.ports.repositories.metric;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class GetMetricsUseCase : UIMUseCase {
  private MetricRepository repo;

  this(MetricRepository repo) {
    this.repo = repo;
  }

  CommandResult patch(PatchMetricsRequest r) {
    if (r.executionid.isEmpty)
      return CommandResult(false, "", "Execution ID is required");
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    Metric m;
    m.id = randomUUID();
    m.tenantId = r.tenantId;
    m.resourceGroupId = r.resourceGroupId;
    m.executionId = r.executionId;

    // Parse metric values
    MetricValue[] vals;
    foreach (pair; r.metrics) {
      if (pair.length >= 2) {
        MetricValue mv;
        mv.name = pair[0];
        mv.value = pair[1];
        mv.type = MetricValueType.string_;
        vals ~= mv;
      }
    }
    m.metrics = vals;

    // Parse tags
    MetricTag[] tags;
    foreach (pair; r.tags) {
      if (pair.length >= 2) {
        MetricTag mt;
        mt.key = pair[0];
        mt.value = pair[1];
        tags ~= mt;
      }
    }
    m.tags = tags;

    // Parse custom info
    CustomInfo[] info;
    foreach (pair; r.customInfo) {
      if (pair.length >= 2) {
        CustomInfo ci;
        ci.key = pair[0];
        ci.value = pair[1];
        info ~= ci;
      }
    }
    m.customInfo = info;

    import core.time : MonoTime;
    m.createdAt = MonoTime.currTime.ticks;

    repo.save(m);
    return CommandResult(true, m.id, "");
  }

  Metric[] listByExecution(ExecutionId execId, ResourceGroupId rgId) {
    return repo.findByExecution(execId, rgId);
  }

  Metric get_(MetricId id, ResourceGroupId rgId) {
    return repo.findById(id, rgId);
  }

  CommandResult remove(MetricId id, ResourceGroupId rgId) {
    repo.remove(id, rgId);
    return CommandResult(true, id.toString, "");
  }
}
