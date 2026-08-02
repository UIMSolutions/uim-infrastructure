module uim.infrastructure.dlang_compiler_service.infrastructure.http.controllers.api_controller;

import uim.infrastructure.dlang_compiler_service.application.dto.compile_command :
    CompileCommand;
import uim.infrastructure.dlang_compiler_service.application.usecases.compile_source :
    CompileSourceUseCase;
import uim.infrastructure.dlang_compiler_service.application.usecases.list_profiles :
    ListProfilesUseCase;
import std.conv : to;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class ApiController {
    private CompileSourceUseCase compileUseCase;
    private ListProfilesUseCase listProfilesUseCase;

    this(CompileSourceUseCase compileUseCase, ListProfilesUseCase listProfilesUseCase) {
        this.compileUseCase = compileUseCase;
        this.listProfilesUseCase = listProfilesUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/compiler/profiles", &listProfiles);
        router.post("/v1/compiler/compile", &compileSource);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{ \"status\": \"ok\", \"service\": \"uim-dlang-compiler-service\" }", HTTPStatus.ok);
    }

    void listProfiles(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, serializeToJsonString(listProfilesUseCase.execute()), HTTPStatus.ok);
    }

    void compileSource(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto result = compileUseCase.execute(
                CompileCommand(
                    requiredString(payload, "sourceCode"),
                    optionalString(payload, "fileName", "snippet.d"),
                    optionalString(payload, "profile", "debug")
                )
            );

            writeJson(res, serializeToJsonString(result), result.success ? HTTPStatus.ok : HTTPStatus.badRequest);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    private string requiredString(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        auto value = j[key].get!string;
        if (value.length == 0) {
            throw new Exception(key ~ " cannot be empty");
        }
        return value;
    }

    private string optionalString(Json j, string key, string fallback) {
        if (!(key in j)) {
            return fallback;
        }
        return j[key].get!string;
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
