/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.metric;

import uim.platform.ai_core.application.usecases.get_metrics;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class MetricController : PlatformController {
  private GetMetricsUseCase uc;

  this(GetMetricsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.patch_("/api/v2/lm/metrics", &handlePatch);
    router.get("/api/v2/lm/metrics", &handleGet);
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      PatchMetricsRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.executionId = j.getString("executionId");
      r.metrics = jsonKeyValuePairs(j, "metrics");
      r.tags = jsonKeyValuePairs(j, "tags");
      r.customInfo = jsonKeyValuePairs(j, "customInfo");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Metrics stored");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto execId = req.params.get("executionId", "");

      if (execid.isEmpty) {
        writeError(res, 400, "executionId query parameter is required");
        return;
      }

      auto metrics = uc.listByExecution(execId, rgId);

      auto jarr = Json.emptyArray;
      foreach (m; metrics) {
        auto mj = Json.emptyObject
        .set("id", m.id)
        .set("executionId", m.executionId)
        .set("createdAt", m.createdAt);

        auto vArr = Json.emptyArray;
        foreach (v; m.metrics) {
          vArr ~= Json.emptyObject
            .set("name", v.name)
            .set("value", v.value);
        }
        mj["metrics"] = vArr;

        auto tArr = Json.emptyArray;
        foreach (t; m.tags) {
          tArr ~= Json.emptyObject
            .set("key", t.key)
            .set("value", t.value);
        }
        mj["tags"] = tArr;

        jarr ~= mj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(metrics.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
