module uim.infrastructure.sdk_ai.infrastructure.http.controllers.ai_api_controller;

import std.conv : to;
import uim.infrastructure.sdk_ai.application.dto.chat_completion_command : ChatCompletionCommand;
import uim.infrastructure.sdk_ai.application.usecases.generate_chat_completion : GenerateChatCompletionUseCase;
import uim.infrastructure.sdk_ai.application.usecases.list_models : ListModelsUseCase;
import uim.infrastructure.sdk_ai.domain.entities.chat : ChatMessage;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class AiApiController {
    private ListModelsUseCase listModelsUseCase;
    private GenerateChatCompletionUseCase generateUseCase;

    this(
        ListModelsUseCase listModelsUseCase,
        GenerateChatCompletionUseCase generateUseCase
    ) {
        this.listModelsUseCase = listModelsUseCase;
        this.generateUseCase = generateUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/api/v1/models", &listModels);
        router.post("/api/v1/chat/completions", &chatCompletions);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = Json.emptyObject;
        body["status"] = Json("ok");
        body["service"] = Json("uim-sdk-ai-service");
        writeJson(res, body, HTTPStatus.ok);
    }

    void listModels(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = readQuery(req, "tenantId", "default");
        auto models = listModelsUseCase.execute(tenantId);

        auto payload = Json.emptyObject;
        payload["tenantId"] = Json(tenantId);
        payload["count"] = Json(cast(int) models.length);

        auto data = Json.emptyArray;
        foreach (model; models) {
            auto entry = Json.emptyObject;
            entry["id"] = Json(model.id);
            entry["provider"] = Json(model.provider);
            entry["purpose"] = Json(model.purpose);
            data ~= entry;
        }
        payload["data"] = data;
        writeJson(res, payload, HTTPStatus.ok);
    }

    void chatCompletions(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto command = ChatCompletionCommand(
                optionalString(json, "tenantId", "default"),
                optionalString(json, "model", "gpt-4o-mini"),
                parseMessages(json),
                optionalDouble(json, "temperature", 0.2),
                optionalInt(json, "max_tokens", 1024)
            );

            auto output = generateUseCase.execute(command);
            auto payload = Json.emptyObject;
            payload["id"] = Json(output.id);
            payload["object"] = Json("chat.completion");
            payload["created"] = Json(cast(long) output.createdAtUnix);
            payload["model"] = Json(output.model);

            auto choice = Json.emptyObject;
            choice["index"] = Json(0);
            auto msg = Json.emptyObject;
            msg["role"] = Json("assistant");
            msg["content"] = Json(output.content);
            choice["message"] = msg;

            auto choices = Json.emptyArray;
            choices ~= choice;
            payload["choices"] = choices;

            auto usage = Json.emptyObject;
            usage["prompt_tokens"] = Json(output.usage.promptTokens);
            usage["completion_tokens"] = Json(output.usage.completionTokens);
            usage["total_tokens"] = Json(output.usage.totalTokens);
            payload["usage"] = usage;

            writeJson(res, payload, HTTPStatus.ok);
        } catch (Exception ex) {
            auto err = Json.emptyObject;
            err["error"] = Json(ex.msg);
            writeJson(res, err, HTTPStatus.badRequest);
        }
    }

    private ChatMessage[] parseMessages(Json requestBody) {
        auto data = requestBody["messages"];
        if (data.type != Json.Type.array || data.length == 0) {
            return [ChatMessage("user", "Hello")];
        }

        ChatMessage[] messages;
        foreach (entry; data) {
            auto role = optionalString(entry, "role", "user");
            auto content = optionalString(entry, "content", "");
            if (content.length == 0) {
                continue;
            }
            messages ~= ChatMessage(role, content);
        }

        if (messages.length == 0) {
            messages ~= ChatMessage("user", "Hello");
        }
        return messages;
    }

    private string readQuery(HTTPServerRequest req, string key, string fallback) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == key && kv.value.length > 0) {
                return kv.value;
            }
        }
        return fallback;
    }

    private string optionalString(Json json, string key, string fallback) {
        auto value = json[key];
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        return fallback;
    }

    private int optionalInt(Json json, string key, int fallback) {
        auto value = json[key];
        if (value.type == Json.Type.int_) {
            return value.get!int;
        }
        return fallback;
    }

    private double optionalDouble(Json json, string key, double fallback) {
        auto value = json[key];
        if (value.type == Json.Type.float_) {
            return value.get!double;
        }
        if (value.type == Json.Type.int_) {
            return value.get!int;
        }
        return fallback;
    }

    private void writeJson(HTTPServerResponse res, Json payload, HTTPStatus status) {
        res.writeBody(serializeToJsonString(payload), cast(int) status, "application/json");
    }
}
