/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.configuration;

import uim.platform.ai_core.application.usecases.manage.configurations;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ConfigurationController : PlatformController {
  private ManageConfigurationsUseCase uc;

  this(ManageConfigurationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v2/lm/configurations", &handleList);
    router.get("/api/v2/lm/configurations/*", &handleGet);
    router.post("/api/v2/lm/configurations", &handleCreate);
    router.delete_("/api/v2/lm/configurations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConfigurationRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.scenarioId = j.getString("scenarioId");
      r.executableId = j.getString("executableId");
      r.name = j.getString("name");
      r.parameterValues = jsonKeyValuePairs(j, "parameterBindings");
      r.inputArtifacts = jsonKeyValuePairs(j, "inputArtifactBindings");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Configuration created");
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto scenarioId = req.params.get("scenarioId", "");

      typeof(uc.list(rgId)) configs;
      if (scenarioId.length > 0)
        configs = uc.listByScenario(scenarioId, rgId);
      else
        configs = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (c; configs) {
        // Parameter bindings
        auto pbArr = c.parameterValues.map!(pv => Json.emptyObject.set("key", pv.key).set("value", pv.value)).array.toJson;
        auto iaArr = c.inputArtifacts.map!(ia => Json.emptyObject.set("key", ia.key).set("artifactId", ia.artifactId)).array.toJson;

        jarr ~= Json.emptyObject
        .set("id", c.id)
        .set("scenarioId", c.scenarioId)
        .set("executableId", c.executableId)
        .set("name", c.name)
        .set("createdAt", c.createdAt)
        .set("parameterBindings", pbArr)
        .set("inputArtifactBindings", iaArr);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(configs.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto c = uc.get_(id, rgId);
      if (c.id.isEmpty) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(c.id);
      resp["scenarioId"] = Json(c.scenarioId);
      resp["executableId"] = Json(c.executableId);
      resp["name"] = Json(c.name);
      resp["createdAt"] = Json(c.createdAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto result = uc.remove(id, rgId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
