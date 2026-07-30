module uim.infrastructure.smtp_relay.infrastructure.http.controllers.web_controller;

import uim.infrastructure.smtp_relay.application.dto.relay_message_command : RelayMessageCommand;
import uim.infrastructure.smtp_relay.application.usecases.get_message : GetMessageUseCase;
import uim.infrastructure.smtp_relay.application.usecases.list_messages : ListMessagesUseCase;
import uim.infrastructure.smtp_relay.application.usecases.relay_message : RelayMessageUseCase;
import uim.infrastructure.smtp_relay.infrastructure.http.views.html_renderer : HtmlRenderer;
import std.conv : to;
import std.string : replace, split, startsWith, strip;
import std.uri : decodeComponent;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private RelayMessageUseCase relayUseCase;
    private ListMessagesUseCase listUseCase;
    private GetMessageUseCase getUseCase;
    private HtmlRenderer renderer;

    this(
        RelayMessageUseCase relayUseCase,
        ListMessagesUseCase listUseCase,
        GetMessageUseCase getUseCase
    ) {
        this.relayUseCase = relayUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
        this.renderer = new HtmlRenderer;
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/compose", &composeForm);
        router.post("/compose", &composeSubmit);
        router.get("/messages", &messages);
        router.get("/messages/*", &messageDetail);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(), HTTPStatus.ok);
    }

    void composeForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCompose("noreply@uim.local"), HTTPStatus.ok);
    }

    void composeSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto command = RelayMessageCommand(
                form.get("sender", ""),
                parseRecipients(form.get("recipients", "")),
                form.get("subject", ""),
                form.get("body", "")
            );

            auto message = relayUseCase.execute(command);
            auto success = "message " ~ message.id ~ " relayed with status " ~ message.status.to!string;
            writeHtml(res, renderer.renderCompose(message.sender, "", success), HTTPStatus.created);
        } catch (Exception ex) {
            writeHtml(res, renderer.renderCompose("noreply@uim.local", ex.msg), HTTPStatus.badRequest);
        }
    }

    void messages(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderMessages(listUseCase.execute()), HTTPStatus.ok);
    }

    void messageDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/messages/");
        if (id.length == 0) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        auto message = getUseCase.execute(id);
        if (message is null) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        writeHtml(res, renderer.renderMessageDetail(*message), HTTPStatus.ok);
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

    private string[] parseRecipients(string source) {
        string[] recipients;
        foreach (part; source.split(",")) {
            auto value = part.strip;
            if (value.length > 0) {
                recipients ~= value;
            }
        }
        return recipients;
    }

    private string decodeForm(string value) {
        return decodeComponent(value.replace("+", " "));
    }

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        auto parts = requestPath[prefix.length .. $].split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
