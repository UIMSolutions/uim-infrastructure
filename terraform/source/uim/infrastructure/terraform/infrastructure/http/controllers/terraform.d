/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.terraform.infrastructure.http.controllers.terraform;

import std.conv : to;
import uim.infrastructure.terraform.application.dto.terraform_command : TerraformCommand;
import uim.infrastructure.terraform.application.usecases.get_terraform_version : GetTerraformVersionUseCase;
import uim.infrastructure.terraform.application.usecases.run_terraform_action : RunTerraformActionUseCase, TerraformAction;
import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult, TerraformRunReport;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class TerraformController {
    private GetTerraformVersionUseCase getTerraformVersionUseCase;
    private RunTerraformActionUseCase runTerraformActionUseCase;

    this(
        GetTerraformVersionUseCase getTerraformVersionUseCase,
        RunTerraformActionUseCase runTerraformActionUseCase
    ) {
        this.getTerraformVersionUseCase = getTerraformVersionUseCase;
        this.runTerraformActionUseCase = runTerraformActionUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/terraform/version", &versionHandler);
        router.post("/v1/terraform/validate", &validate);
        router.post("/v1/terraform/plan", &plan);
        router.post("/v1/terraform/apply", &apply);
        router.post("/v1/terraform/destroy", &destroy);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["status"] = Json("ok");
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void versionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        auto result = getTerraformVersionUseCase.execute();

        Json payload = Json.emptyObject;
        payload["step"] = Json(result.step);
        payload["exit_code"] = Json(result.exitCode);
        payload["stdout"] = Json(result.stdoutText);
        payload["stderr"] = Json(result.stderrText);
        payload["success"] = Json(result.successful);

        writeJson(res, serializeToJsonString(payload), result.successful ? HTTPStatus.ok : HTTPStatus.badRequest);
    }

    void validate(HTTPServerRequest req, HTTPServerResponse res) {
        runAction(req, res, TerraformAction.validate);
    }

    void plan(HTTPServerRequest req, HTTPServerResponse res) {
        runAction(req, res, TerraformAction.plan);
    }

    void apply(HTTPServerRequest req, HTTPServerResponse res) {
        runAction(req, res, TerraformAction.apply);
    }

    void destroy(HTTPServerRequest req, HTTPServerResponse res) {
        runAction(req, res, TerraformAction.destroy_);
    }

    private void runAction(HTTPServerRequest req, HTTPServerResponse res, TerraformAction action) {
        try {
            auto command = parseCommand(req);
            auto report = runTerraformActionUseCase.execute(action, command);
            auto status = report.successful ? HTTPStatus.ok : HTTPStatus.badRequest;
            writeJson(res, serializeToJsonString(reportToJson(report)), status);
        } catch (Exception ex) {
            Json payload = Json.emptyObject;
            payload["error"] = Json(ex.msg);
            writeJson(res, serializeToJsonString(payload), HTTPStatus.badRequest);
        }
    }

    private TerraformCommand parseCommand(HTTPServerRequest req) {
        auto body = req.json;
        auto commandJson = body;
        if (body["command"].type == Json.Type.object) {
            commandJson = body["command"];
        }

        TerraformCommand command;
        command.workspace = readString(commandJson, "workspace", "");
        command.modulePath = readString(commandJson, "module_path", "");
        command.autoApprove = readBool(commandJson, "auto_approve", true);
        command.variables = readStringMap(commandJson["variables"]);

        return command;
    }

    private string readString(Json root, string key, string fallback) {
        auto value = root[key];
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        return fallback;
    }

    private bool readBool(Json root, string key, bool fallback) {
        auto value = root[key];
        if (value.type == Json.Type.bool_) {
            return value.get!bool;
        }
        return fallback;
    }

    private string[string] readStringMap(Json value) {
        string[string] map;
        if (value.type != Json.Type.object) {
            return map;
        }

        foreach (string key, Json item; value) {
            final switch (item.type) {
                case Json.Type.string:
                    map[key] = item.get!string;
                    break;
                case Json.Type.int_:
                    map[key] = item.get!long.to!string;
                    break;
                case Json.Type.bigInt:
                    map[key] = item.get!string;
                    break;
                case Json.Type.float_:
                    map[key] = item.get!double.to!string;
                    break;
                case Json.Type.bool_:
                    map[key] = item.get!bool ? "true" : "false";
                    break;
                case Json.Type.null_:
                case Json.Type.undefined:
                case Json.Type.array:
                case Json.Type.object:
                    break;
            }
        }

        return map;
    }

    private Json reportToJson(in TerraformRunReport report) {
        Json payload = Json.emptyObject;
        payload["action"] = Json(report.action);
        payload["module_path"] = Json(report.modulePath);
        payload["workspace"] = Json(report.workspace);
        payload["success"] = Json(report.successful);

        Json[] stepItems;
        foreach (step; report.steps) {
            stepItems ~= stepToJson(step);
        }

        payload["steps"] = Json(stepItems);
        return payload;
    }

    private Json stepToJson(in TerraformExecutionResult step) {
        Json payload = Json.emptyObject;
        payload["step"] = Json(step.step);
        payload["exit_code"] = Json(step.exitCode);
        payload["stdout"] = Json(step.stdoutText);
        payload["stderr"] = Json(step.stderrText);
        payload["success"] = Json(step.successful);
        return payload;
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}