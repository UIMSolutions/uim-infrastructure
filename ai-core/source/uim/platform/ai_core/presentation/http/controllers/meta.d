/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.meta;

import uim.platform.ai_core;

class MetaController : PlatformController {
  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v2/lm/meta", &handleMeta);
  }

  private void handleMeta(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto j = Json.emptyObject;

    // AI API capabilities
    auto aiApi = Json.emptyObject;
    auto caps = Json.emptyObject;

    auto logs = Json.emptyObject;
    logs["executions"] = Json(true);
    logs["deployments"] = Json(true);
    caps["logs"] = logs;

    caps["multitenant"] = Json(true);
    caps["shareable"] = Json(true);
    caps["staticDeployments"] = Json(false);
    caps["userDeployments"] = Json(true);
    caps["userExecutions"] = Json(true);
    caps["executionSchedules"] = Json(true);
    caps["bulkUpdates"] = Json(true);
    caps["timeToLiveDeployments"] = Json(true);

    aiApi["capabilities"] = caps;

    auto limits = Json.emptyObject;
    auto deplLimits = Json.emptyObject;
    deplLimits["maxRunningCount"] = Json(-1);
    limits["deployments"] = deplLimits;

    auto execLimits = Json.emptyObject;
    execLimits["maxRunningCount"] = Json(-1);
    limits["executions"] = execLimits;

    limits["minimumFrequencyHour"] = Json(1);

    auto ttlLimits = Json.emptyObject;
    ttlLimits["minimum"] = Json("10m");
    ttlLimits["maximum"] = Json(-1);
    limits["timeToLiveDeployments"] = ttlLimits;

    aiApi["limits"] = limits;
    aiApi["version"] = Json("2.18.0");

    j["aiApi"] = aiApi;

    // Extensions
    auto ext = Json.emptyObject;

    auto analytics = Json.emptyObject;
    analytics["version"] = Json("1.0.0");
    ext["analytics"] = analytics;

    auto metrics = Json.emptyObject;
    auto metricCaps = Json.emptyObject;
    metricCaps["extendedResults"] = Json(true);
    metrics["capabilities"] = metricCaps;
    metrics["version"] = Json("1.0.0");
    ext["metrics"] = metrics;

    auto rgExt = Json.emptyObject;
    rgExt["version"] = Json("1.2.0");
    ext["resourceGroups"] = rgExt;

    j["extensions"] = ext;
    j["runtimeApiVersion"] = Json("2.21.0");
    j["runtimeIdentifier"] = Json("uim-ai-core");

    res.writeJsonBody(j, 200);
  }
}
