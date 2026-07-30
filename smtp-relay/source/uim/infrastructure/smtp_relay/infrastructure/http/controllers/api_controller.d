module uim.infrastructure.smtp_relay.infrastructure.http.controllers.api_controller;

import uim.infrastructure.smtp_relay.application.dto.relay_message_command : RelayMessageCommand;
import uim.infrastructure.smtp_relay.application.usecases.get_message : GetMessageUseCase;
import uim.infrastructure.smtp_relay.application.usecases.list_messages : ListMessagesUseCase;
import uim.infrastructure.smtp_relay.application.usecases.relay_message : RelayMessageUseCase;
import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import std.conv : to;
import std.string : split, startsWith, strip;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

struct MessageView {
    string id;
    string sender;
    string[] recipients;
    string subject;
    string body;
    string status;
    string createdAt;
    string relayError;
}

class ApiController {
    private RelayMessageUseCase relayUseCase;
    private ListMessagesUseCase listUseCase;
    private GetMessageUseCase getUseCase;

    this(
        RelayMessageUseCase relayUseCase,
        ListMessagesUseCase listUseCase,
        GetMessageUseCase getUseCase
    ) {
        this.relayUseCase = relayUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/api/v1/messages", &listMessages);
        router.get("/api/v1/messages/*", &getMessage);
        router.post("/api/v1/messages", &relayMessage);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok"}`, HTTPStatus.ok);
    }

    void listMessages(HTTPServerRequest req, HTTPServerResponse res) {
        auto messages = listUseCase.execute();
        MessageView[] views;
        foreach (message; messages) {
            views ~= toView(message);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getMessage(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/api/v1/messages/");
        if (id.length == 0) {
            writeJson(res, `{"error":"expected /api/v1/messages/<id>"}`, HTTPStatus.badRequest);
            return;
        }

        auto message = getUseCase.execute(id);
        if (message is null) {
            writeJson(res, `{"error":"message not found"}`, HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toView(*message)), HTTPStatus.ok);
    }

    void relayMessage(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());

            auto command = RelayMessageCommand(
                readOptionalString(payload, "sender"),
                readRecipients(payload),
                readRequiredString(payload, "subject"),
                readRequiredString(payload, "body")
            );

            auto message = relayUseCase.execute(command);
            writeJson(res, serializeToJsonString(toView(message)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{"error":"` ~ ex.msg ~ `"}`, HTTPStatus.badRequest);
        }
    }

    private MessageView toView(in EmailMessage message) {
        auto recipients = message.recipients.dup;

        return MessageView(
            message.id,
            message.sender,
            recipients,
            message.subject,
            message.body,
            message.status.to!string,
            message.createdAt.toISOExtString(),
            message.relayError
        );
    }

    private string readOptionalString(Json payload, string key) {
        auto entry = key in payload;
        if (entry is null) {
            return "";
        }

        return payload[key].get!string;
    }

    private string readRequiredString(Json payload, string key) {
        auto entry = key in payload;
        if (entry is null) {
            throw new Exception(key ~ " is required");
        }

        return payload[key].get!string;
    }

    private string[] readRecipients(Json payload) {
        auto entry = "recipients" in payload;
        if (entry is null) {
            throw new Exception("recipients is required");
        }

        string[] recipients;
        auto recipientsNode = payload["recipients"];

        if (recipientsNode.type == Json.Type.array) {
            foreach (recipient; recipientsNode) {
                recipients ~= recipient.get!string;
            }
            return recipients;
        }

        if (recipientsNode.type == Json.Type.string) {
            foreach (part; recipientsNode.get!string.split(",")) {
                auto value = part.strip;
                if (value.length > 0) {
                    recipients ~= value;
                }
            }
            return recipients;
        }

        throw new Exception("recipients must be an array or comma separated string");
    }

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        auto parts = requestPath[prefix.length .. $].split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
