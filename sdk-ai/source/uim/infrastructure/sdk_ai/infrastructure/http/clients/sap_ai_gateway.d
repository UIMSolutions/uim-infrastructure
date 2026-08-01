module uim.infrastructure.sdk_ai.infrastructure.http.clients.sap_ai_gateway;

import std.conv : to;
import std.datetime : Clock;
import std.exception : collectException;
import std.string : strip;
import uim.infrastructure.sdk_ai.domain.entities.chat :
    ChatCompletionRequest,
    ChatCompletionResponse,
    ChatMessage,
    TokenUsage;
import uim.infrastructure.sdk_ai.domain.entities.model_info : ModelInfo;
import uim.infrastructure.sdk_ai.domain.ports.ai_model_gateway : IAiModelGateway;
import uim.infrastructure.sdk_ai.infrastructure.config.settings : ServiceSettings;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod, HTTPStatus;
import vibe.inet.url : URL;
import vibe.stream.operations : readAllUTF8;

class SapAiGateway : IAiModelGateway {
    private ServiceSettings settings;

    this(ServiceSettings settings) {
        this.settings = settings;
    }

    override ModelInfo[] listModels(string tenantId) {
        auto normalizedTenant = tenantId.length == 0 ? settings.defaultTenantId : tenantId;
        if (!isRemoteConfigured()) {
            return [
                ModelInfo("gpt-4o-mini", settings.sdkProvider, "chat-completion"),
                ModelInfo("gpt-4.1-mini", settings.sdkProvider, "chat-completion"),
                ModelInfo("text-embedding-3-small", settings.sdkProvider, "embedding")
            ];
        }

        int status = 0;
        string body;
        auto url = URL(composeUrl("/v1/models"));

        auto err = collectException({
            requestHTTP(
                url,
                (scope reqOut) {
                    reqOut.method = HTTPMethod.GET;
                    applyHeaders(reqOut.headers, normalizedTenant);
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        if (err !is null || status < 200 || status >= 300) {
            return [ModelInfo("gpt-4o-mini", settings.sdkProvider, "chat-completion")];
        }

        return parseModels(body);
    }

    override ChatCompletionResponse generateChatCompletion(ChatCompletionRequest request) {
        if (!isRemoteConfigured()) {
            return localFallback(request);
        }

        auto payload = buildCompletionPayload(request);

        int status = 0;
        string body;
        auto url = URL(composeUrl("/v1/chat/completions"));

        auto err = collectException({
            requestHTTP(
                url,
                (scope reqOut) {
                    reqOut.method = HTTPMethod.POST;
                    applyHeaders(reqOut.headers, request.tenantId);
                    reqOut.writeBody(cast(ubyte[]) serializeToJsonString(payload), "application/json");
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        if (err !is null || status < 200 || status >= 300 || body.length == 0) {
            return localFallback(request);
        }

        auto parsed = parseCompletionResponse(body, request.model);
        if (parsed.content.length == 0) {
            return localFallback(request);
        }
        return parsed;
    }

    private bool isRemoteConfigured() {
        return settings.aiBaseUrl.strip().length > 0 && settings.aiApiKey.strip().length > 0;
    }

    private string composeUrl(string path) {
        auto base = settings.aiBaseUrl.strip();
        if (base.length == 0) {
            return "";
        }
        if (base[$ - 1] == '/') {
            base = base[0 .. $ - 1];
        }
        return base ~ path;
    }

    private void applyHeaders(H)(ref H headers, string tenantId) {
        headers["Authorization"] = "Bearer " ~ settings.aiApiKey;
        headers["Accept"] = "application/json";
        headers["X-Resource-Group"] = settings.aiResourceGroup;
        headers["X-Tenant-Id"] = tenantId.length == 0 ? settings.defaultTenantId : tenantId;
        headers["X-Deployment-Id"] = settings.aiDeploymentId;
    }

    private Json buildCompletionPayload(ChatCompletionRequest request) {
        auto payload = Json.emptyObject;
        payload["model"] = Json(request.model);
        payload["temperature"] = Json(request.temperature);
        payload["max_tokens"] = Json(request.maxTokens);

        auto messageArray = Json.emptyArray;
        foreach (message; request.messages) {
            auto entry = Json.emptyObject;
            entry["role"] = Json(message.role);
            entry["content"] = Json(message.content);
            messageArray ~= entry;
        }
        payload["messages"] = messageArray;
        return payload;
    }

    private ModelInfo[] parseModels(string body) {
        auto parsed = parseJsonString(body);
        auto data = parsed["data"];
        if (data.type != Json.Type.array) {
            return [ModelInfo("gpt-4o-mini", settings.sdkProvider, "chat-completion")];
        }

        ModelInfo[] models;
        foreach (item; data) {
            auto id = item["id"].type == Json.Type.string ? item["id"].get!string : "";
            if (id.length == 0) {
                continue;
            }
            auto purpose = item["purpose"].type == Json.Type.string ? item["purpose"].get!string : "chat-completion";
            models ~= ModelInfo(id, settings.sdkProvider, purpose);
        }

        if (models.length == 0) {
            models ~= ModelInfo("gpt-4o-mini", settings.sdkProvider, "chat-completion");
        }
        return models;
    }

    private ChatCompletionResponse parseCompletionResponse(string body, string requestModel) {
        auto parsed = parseJsonString(body);
        auto id = parsed["id"].type == Json.Type.string ? parsed["id"].get!string : "";
        auto model = parsed["model"].type == Json.Type.string ? parsed["model"].get!string : requestModel;
        auto content = "";

        auto choices = parsed["choices"];
        if (choices.type == Json.Type.array && choices.length > 0) {
            auto message = choices[0]["message"];
            if (message.type == Json.Type.object && message["content"].type == Json.Type.string) {
                content = message["content"].get!string;
            }
        }

        auto usageJson = parsed["usage"];
        auto promptTokens = usageJson["prompt_tokens"].type == Json.Type.int_ ? usageJson["prompt_tokens"].get!int : 0;
        auto completionTokens = usageJson["completion_tokens"].type == Json.Type.int_ ? usageJson["completion_tokens"].get!int : 0;
        auto totalTokens = usageJson["total_tokens"].type == Json.Type.int_ ? usageJson["total_tokens"].get!int : 0;

        return ChatCompletionResponse(
            id,
            settings.sdkProvider,
            model,
            content,
            Clock.currTime().toUnixTime!long,
            TokenUsage(promptTokens, completionTokens, totalTokens)
        );
    }

    private ChatCompletionResponse localFallback(ChatCompletionRequest request) {
        string lastPrompt;
        foreach_reverse (message; request.messages) {
            if (message.role == "user") {
                lastPrompt = message.content;
                break;
            }
        }
        if (lastPrompt.length == 0) {
            lastPrompt = "Hello from local fallback";
        }

        auto completion = "[local-fallback] " ~ lastPrompt ~ " | model=" ~ request.model;
        auto now = Clock.currTime().toUnixTime!long;
        return ChatCompletionResponse(
            "local-" ~ now.to!string,
            settings.sdkProvider,
            request.model,
            completion,
            now,
            TokenUsage(cast(int) lastPrompt.length, cast(int) completion.length, cast(int) (lastPrompt.length + completion.length))
        );
    }
}
