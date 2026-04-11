/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.deployment;

import uim.platform.ai_core.application.usecases.manage.deployments;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class DeploymentController : PlatformController {
  private ManageDeploymentsUseCase uc;

  this(ManageDeploymentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/deployments", &handleCreate);
    router.get("/api/v2/lm/deployments", &handleList);
    router.get("/api/v2/lm/deployments/*", &handleGet);
    router.patch_("/api/v2/lm/deployments/*", &handlePatch);
    router.delete_("/api/v2/lm/deployments/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDeploymentRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.configurationId = j.getString("configurationId");
      r.ttl = jsonInt(j, "ttl");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Deployment scheduled");
        resp["status"] = Json("PENDING");
        res.writeJsonBody(resp, 202);
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
      auto deployments = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (d; deployments) {
        jarr ~= deploymentToJson(d);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(deployments.length);
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

      auto d = uc.get_(id, rgId);
      if (d.id.isEmpty) {
        writeError(res, 404, "Deployment not found");
        return;
      }

      res.writeJsonBody(deploymentToJson(d), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      PatchDeploymentRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.deploymentId = id;
      r.targetStatus = j.getString("targetStatus");
      r.configurationId = j.getString("configurationId");
      r.ttl = jsonInt(j, "ttl");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Deployment modified");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
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

  private Json deploymentToJson(Deployment d) {
    import std.conv : to;

    return Json.emptyObject
      .set("id", d.id)
      .set("configurationId", d.configurationId)
      .set("scenarioId", d.scenarioId)
      .set("executableId", d.executableId)
      .set("status", d.status.to!string)
      .set("statusMessage", d.statusMessage)
      .set("deploymentUrl", d.deploymentUrl)
      .set("ttl", d.ttl)
      .set("createdAt", d.createdAt)
      .set("modifiedAt", d.modifiedAt)
      .set("startedAt", d.startedAt)
      .set("completedAt", d.completedAt);
  }
}
