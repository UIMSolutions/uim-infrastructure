/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.scenario;

import uim.platform.ai_core.application.usecases.manage.scenarios;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ScenarioController : PlatformController {
  private ManageScenariosUseCase uc;

  this(ManageScenariosUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v2/lm/scenarios", &handleList);
    router.get("/api/v2/lm/scenarios/*", &handleGet);
    router.post("/api/v2/lm/scenarios", &handleCreate);
    router.delete_("/api/v2/lm/scenarios/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateScenarioRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.labels = jsonStrArray(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Scenario registered");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto scenarios = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (s; scenarios) {
        jarr ~= Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("labels", s.labels)
        .set("createdAt", s.createdAt)
        .set("modifiedAt", s.modifiedAt);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(scenarios.length);
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

      auto s = uc.get_(id, rgId);
      if (s.id.isEmpty) {
        writeError(res, 404, "Scenario not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(s.id);
      resp["name"] = Json(s.name);
      resp["description"] = Json(s.description);
      resp["labels"] = toJsonArray(s.labels);
      resp["createdAt"] = Json(s.createdAt);
      resp["modifiedAt"] = Json(s.modifiedAt);
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
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
