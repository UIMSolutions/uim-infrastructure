/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.resource_group;

import uim.platform.ai_core.application.usecases.manage.resource_groups;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ResourceGroupController : PlatformController {
  private ManageResourceGroupsUseCase uc;

  this(ManageResourceGroupsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v2/admin/resourceGroups", &handleCreate);
    router.get("/api/v2/admin/resourceGroups", &handleList);
    router.get("/api/v2/admin/resourceGroups/*", &handleGet);
    router.patch_("/api/v2/admin/resourceGroups/*", &handlePatch);
    router.delete_("/api/v2/admin/resourceGroups/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateResourceGroupRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = j.getString("resourceGroupId");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["resourceGroupId"] = Json(result.id);
        resp["message"] = Json("Resource group created");
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
      TenantId tenantId = req.getTenantId;
      auto groups = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (rg; groups) {
        auto rgj = Json.emptyObject
          .set("resourceGroupId", rg.id)
          .set("tenantId", rg.tenantId)
          .set("status", rg.status)
          .set("createdAt", rg.createdAt);

        auto lArr = Json.emptyArray;
        foreach (lbl; rg.labels) {
          auto lj = Json.emptyObject
            .set("key", lbl.key)
            .set("value", lbl.value);
          lArr ~= lj;
        }
        rgj["labels"] = lArr;

        jarr ~= rgj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(groups.length);
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

      auto rg = uc.get_(id);
      if (rg.id.isEmpty) {
        writeError(res, 404, "Resource group not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["resourceGroupId"] = Json(rg.id);
      resp["tenantId"] = Json(rg.tenantId);
      resp["status"] = Json(rg.status);
      resp["createdAt"] = Json(rg.createdAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      PatchResourceGroupRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = id;
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["resourceGroupId"] = Json(result.id);
        resp["message"] = Json("Resource group updated");
        res.writeJsonBody(resp, 200);
      } ) {
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

      auto result = uc.remove(id);
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
