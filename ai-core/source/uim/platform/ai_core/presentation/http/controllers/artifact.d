/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.artifact;

import uim.platform.ai_core.application.usecases.manage.artifacts;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ArtifactController : PlatformController {
  private ManageArtifactsUseCase uc;

  this(ManageArtifactsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/artifacts", &handleCreate);
    router.get("/api/v2/lm/artifacts", &handleList);
    router.get("/api/v2/lm/artifacts/*", &handleGet);
    router.delete_("/api/v2/lm/artifacts/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateArtifactRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.kind = j.getString("kind");
      r.url = j.getString("url");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Artifact registered");
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

      typeof(uc.list(rgId)) artifacts;
      if (scenarioId.length > 0)
        artifacts = uc.listByScenario(scenarioId, rgId);
      else
        artifacts = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (a; artifacts) {
        jarr ~= artifactToJson(a);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(artifacts.length);
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

      auto a = uc.get_(id, rgId);
      if (a.id.isEmpty) {
        writeError(res, 404, "Artifact not found");
        return;
      }

      res.writeJsonBody(artifactToJson(a), 200);
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

  private Json artifactToJson(Artifact a) {
    import std.conv : to;

    auto lArr = Json.emptyArray;
    foreach (lbl; a.labels) {
      lArr ~= Json.emptyObject
        .set("key", Json(lbl.key))
        .set("value", Json(lbl.value));
    }

    return Json.emptyObject
      .set("id", a.id)
      .set("scenarioId", a.scenarioId)
      .set("executionId", a.executionId)
      .set("name", a.name)
      .set("description", a.description)
      .set("kind", a.kind.to!string)
      .set("url", a.url)
      .set("createdAt", a.createdAt)
      .set("modifiedAt", a.modifiedAt)
      .set("labels", lArr);
  }
}
