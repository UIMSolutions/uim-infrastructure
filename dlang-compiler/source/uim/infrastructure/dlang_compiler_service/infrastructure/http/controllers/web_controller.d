module uim.infrastructure.dlang_compiler_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.dlang_compiler_service.application.dto.compile_command :
    CompileCommand;
import uim.infrastructure.dlang_compiler_service.application.usecases.compile_source :
    CompileSourceUseCase;
import uim.infrastructure.dlang_compiler_service.application.usecases.list_profiles :
    ListProfilesUseCase;
import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompileResult;
import uim.infrastructure.dlang_compiler_service.infrastructure.http.views.html_renderer :
    HtmlRenderer;
import std.string : replace, split;
import std.uri : decodeComponent;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private CompileSourceUseCase compileUseCase;
    private ListProfilesUseCase listProfilesUseCase;
    private HtmlRenderer renderer;

    this(CompileSourceUseCase compileUseCase, ListProfilesUseCase listProfilesUseCase) {
        this.compileUseCase = compileUseCase;
        this.listProfilesUseCase = listProfilesUseCase;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/compile", &compileForm);
        router.post("/compile", &compileSubmit);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(listProfilesUseCase.execute()), HTTPStatus.ok);
    }

    void compileForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCompileForm(listProfilesUseCase.execute()), HTTPStatus.ok);
    }

    void compileSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto result = compileUseCase.execute(
                CompileCommand(
                    form.get("sourceCode", ""),
                    form.get("fileName", "snippet.d"),
                    form.get("profile", "debug")
                )
            );

            auto status = result.success ? HTTPStatus.ok : HTTPStatus.badRequest;
            writeHtml(
                res,
                renderer.renderCompileForm(listProfilesUseCase.execute(), "", &result),
                status
            );
        } catch (Exception ex) {
            writeHtml(
                res,
                renderer.renderCompileForm(listProfilesUseCase.execute(), ex.msg),
                HTTPStatus.badRequest
            );
        }
    }

    private string[string] parseForm(string body) {
        string[string] result;

        foreach (pair; body.split("&")) {
            if (pair.length == 0) {
                continue;
            }

            auto parts = pair.split("=");
            auto key = decodeForm(parts.length > 0 ? parts[0] : "");
            auto value = decodeForm(parts.length > 1 ? parts[1] : "");
            result[key] = value;
        }

        return result;
    }

    private string decodeForm(string value) {
        return decodeComponent(value.replace("+", " "));
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
