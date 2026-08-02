module uim.infrastructure.dlang_formatter_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.dlang_formatter_service.application.dto.format_command :
    FormatCommand;
import uim.infrastructure.dlang_formatter_service.application.usecases.format_source :
    FormatSourceUseCase;
import uim.infrastructure.dlang_formatter_service.application.usecases.list_profiles :
    ListProfilesUseCase;
import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatResult;
import uim.infrastructure.dlang_formatter_service.infrastructure.http.views.html_renderer :
    HtmlRenderer;
import std.string : replace, split;
import std.uri : decodeComponent;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private FormatSourceUseCase formatUseCase;
    private ListProfilesUseCase listProfilesUseCase;
    private HtmlRenderer renderer;

    this(FormatSourceUseCase formatUseCase, ListProfilesUseCase listProfilesUseCase) {
        this.formatUseCase = formatUseCase;
        this.listProfilesUseCase = listProfilesUseCase;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/format", &formatForm);
        router.post("/format", &formatSubmit);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(listProfilesUseCase.execute()), HTTPStatus.ok);
    }

    void formatForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderFormatForm(listProfilesUseCase.execute()), HTTPStatus.ok);
    }

    void formatSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto result = formatUseCase.execute(
                FormatCommand(
                    form.get("sourceCode", ""),
                    form.get("fileName", "snippet.d"),
                    form.get("profile", "default")
                )
            );

            auto status = result.success ? HTTPStatus.ok : HTTPStatus.badRequest;
            writeHtml(
                res,
                renderer.renderFormatForm(listProfilesUseCase.execute(), "", &result),
                status
            );
        } catch (Exception ex) {
            writeHtml(
                res,
                renderer.renderFormatForm(listProfilesUseCase.execute(), ex.msg),
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
