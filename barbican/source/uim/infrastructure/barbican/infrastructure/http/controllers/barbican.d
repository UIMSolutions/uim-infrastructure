module uim.infrastructure.barbican.infrastructure.http.controllers.barbican;

import uim.infrastructure.barbican.application.dto.commands;
import uim.infrastructure.barbican.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.barbican.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.barbican.application.usecases.get_secret : GetSecretUseCase;
import uim.infrastructure.barbican.application.usecases.delete_secret : DeleteSecretUseCase;
import uim.infrastructure.barbican.application.usecases.set_secret_payload : SetSecretPayloadUseCase;
import uim.infrastructure.barbican.application.usecases.get_secret_payload : GetSecretPayloadUseCase;
import uim.infrastructure.barbican.application.usecases.create_container : CreateContainerUseCase;
import uim.infrastructure.barbican.application.usecases.list_containers : ListContainersUseCase;
import uim.infrastructure.barbican.application.usecases.get_container : GetContainerUseCase;
import uim.infrastructure.barbican.application.usecases.delete_container : DeleteContainerUseCase;
import uim.infrastructure.barbican.application.usecases.create_order : CreateOrderUseCase;
import uim.infrastructure.barbican.application.usecases.list_orders : ListOrdersUseCase;
import uim.infrastructure.barbican.application.usecases.get_order : GetOrderUseCase;
import uim.infrastructure.barbican.application.usecases.delete_order : DeleteOrderUseCase;
import uim.infrastructure.barbican.domain.entities.secret : Secret;
import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer, SecretRef;
import uim.infrastructure.barbican.domain.entities.order : Order;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

// --------------------------------------------------------------------------
// View types (serialization-friendly projections)
// --------------------------------------------------------------------------

struct SecretView {
    string id;
    string name;
    string secretType;
    string algorithm;
    uint   bitLength;
    string mode;
    string payloadContentType;
    string expiration;
    string status;
    string createdAt;
    string updatedAt;
    string projectId;
    bool   hasPayload;
}

struct SecretRefView {
    string name;
    string secretId;
}

struct ContainerView {
    string id;
    string name;
    string containerType;
    SecretRefView[] secretRefs;
    string createdAt;
    string updatedAt;
    string projectId;
}

struct OrderMetaView {
    string algorithm;
    uint   bitLength;
    string mode;
    string payloadContentType;
    string expiration;
    string name;
}

struct OrderView {
    string       id;
    string       orderType;
    string       status;
    OrderMetaView meta;
    string       secretRef;
    string       createdAt;
    string       updatedAt;
    string       projectId;
    string       errorStatusCode;
    string       errorReason;
}

// --------------------------------------------------------------------------
// Controller
// --------------------------------------------------------------------------

class BarbicanController {
    private CreateSecretUseCase    createSecretUC;
    private ListSecretsUseCase     listSecretsUC;
    private GetSecretUseCase       getSecretUC;
    private DeleteSecretUseCase    deleteSecretUC;
    private SetSecretPayloadUseCase setPayloadUC;
    private GetSecretPayloadUseCase getPayloadUC;
    private CreateContainerUseCase  createContainerUC;
    private ListContainersUseCase   listContainersUC;
    private GetContainerUseCase     getContainerUC;
    private DeleteContainerUseCase  deleteContainerUC;
    private CreateOrderUseCase      createOrderUC;
    private ListOrdersUseCase       listOrdersUC;
    private GetOrderUseCase         getOrderUC;
    private DeleteOrderUseCase      deleteOrderUC;

    this(
        CreateSecretUseCase    createSecretUC,
        ListSecretsUseCase     listSecretsUC,
        GetSecretUseCase       getSecretUC,
        DeleteSecretUseCase    deleteSecretUC,
        SetSecretPayloadUseCase setPayloadUC,
        GetSecretPayloadUseCase getPayloadUC,
        CreateContainerUseCase  createContainerUC,
        ListContainersUseCase   listContainersUC,
        GetContainerUseCase     getContainerUC,
        DeleteContainerUseCase  deleteContainerUC,
        CreateOrderUseCase      createOrderUC,
        ListOrdersUseCase       listOrdersUC,
        GetOrderUseCase         getOrderUC,
        DeleteOrderUseCase      deleteOrderUC
    ) {
        this.createSecretUC    = createSecretUC;
        this.listSecretsUC     = listSecretsUC;
        this.getSecretUC       = getSecretUC;
        this.deleteSecretUC    = deleteSecretUC;
        this.setPayloadUC      = setPayloadUC;
        this.getPayloadUC      = getPayloadUC;
        this.createContainerUC = createContainerUC;
        this.listContainersUC  = listContainersUC;
        this.getContainerUC    = getContainerUC;
        this.deleteContainerUC = deleteContainerUC;
        this.createOrderUC     = createOrderUC;
        this.listOrdersUC      = listOrdersUC;
        this.getOrderUC        = getOrderUC;
        this.deleteOrderUC     = deleteOrderUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        // Secrets
        router.get   ("/v1/secrets",          &listSecrets);
        router.post  ("/v1/secrets",          &createSecret);
        router.get   ("/v1/secrets/*",        &getSecret);
        router.delete_("/v1/secrets/*",       &deleteSecret);
        // Two-step payload: PUT /v1/secrets/{id}  and  GET /v1/secrets/{id}/payload
        router.put   ("/v1/secrets/*",        &putSecretPayload);

        // Containers
        router.get   ("/v1/containers",       &listContainers);
        router.post  ("/v1/containers",       &createContainer);
        router.get   ("/v1/containers/*",     &getContainer);
        router.delete_("/v1/containers/*",    &deleteContainer);

        // Orders
        router.get   ("/v1/orders",           &listOrders);
        router.post  ("/v1/orders",           &createOrder);
        router.get   ("/v1/orders/*",         &getOrder);
        router.delete_("/v1/orders/*",        &deleteOrder);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok","service":"uim-barbican-service"}`, HTTPStatus.ok);
    }

    // --- Secrets ---

    void listSecrets(HTTPServerRequest req, HTTPServerResponse res) {
        string projectId = "";
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "project_id") { projectId = kv.value; break; }
        }
        auto items = listSecretsUC.execute(projectId);
        SecretView[] views;
        foreach (ref s; items) views ~= toSecretView(s);
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void createSecret(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateSecretCommand(
                jsonString(json, "name"),
                jsonString(json, "secret_type"),
                jsonString(json, "algorithm"),
                jsonUint(json, "bit_length"),
                jsonString(json, "mode"),
                jsonString(json, "payload"),
                jsonString(json, "payload_content_type"),
                jsonString(json, "expiration"),
                jsonString(json, "project_id")
            );
            auto created = createSecretUC.execute(cmd);
            writeJson(res, serializeToJsonString(toSecretView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;

        // Route: GET /v1/secrets/{id}/payload
        if (path.length > "/v1/secrets/".length) {
            auto rest = path["/v1/secrets/".length .. $];
            auto parts = rest.split("/");
            if (parts.length == 2 && parts[1] == "payload") {
                getSecretPayload(parts[0], req, res);
                return;
            }
        }

        auto id = extractId(path, "/v1/secrets/");
        if (id.length == 0) { writeError(res, "missing secret id", HTTPStatus.badRequest); return; }

        auto ptr = getSecretUC.execute(id);
        if (ptr is null) { writeError(res, "secret not found", HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(toSecretView(*ptr)), HTTPStatus.ok);
    }

    void deleteSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/secrets/");
        if (id.length == 0) { writeError(res, "missing secret id", HTTPStatus.badRequest); return; }
        try {
            deleteSecretUC.execute(id);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    // PUT /v1/secrets/{id}  — add payload to a two-step secret
    void putSecretPayload(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/secrets/");
        if (id.length == 0) { writeError(res, "missing secret id", HTTPStatus.badRequest); return; }
        try {
            auto json = req.json;
            auto cmd = SetSecretPayloadCommand(
                id,
                jsonString(json, "payload"),
                jsonString(json, "payload_content_type")
            );
            setPayloadUC.execute(cmd);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    private void getSecretPayload(string id, HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto result = getPayloadUC.execute(id);
            auto ct = result.contentType.length > 0 ? result.contentType : "application/octet-stream";
            res.writeBody(result.payload, cast(int) HTTPStatus.ok, ct);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    // --- Containers ---

    void listContainers(HTTPServerRequest req, HTTPServerResponse res) {
        string projectId = "";
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "project_id") { projectId = kv.value; break; }
        }
        auto items = listContainersUC.execute(projectId);
        ContainerView[] views;
        foreach (ref c; items) views ~= toContainerView(c);
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void createContainer(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            SecretRefCommand[] refs;
            if (json["secret_refs"].type == Json.Type.array) {
                foreach (ref rj; json["secret_refs"].byValue()) {
                    refs ~= SecretRefCommand(
                        jsonString(rj, "name"),
                        jsonString(rj, "secret_id")
                    );
                }
            }
            auto cmd = CreateContainerCommand(
                jsonString(json, "name"),
                jsonString(json, "type"),
                refs,
                jsonString(json, "project_id")
            );
            auto created = createContainerUC.execute(cmd);
            writeJson(res, serializeToJsonString(toContainerView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getContainer(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/containers/");
        if (id.length == 0) { writeError(res, "missing container id", HTTPStatus.badRequest); return; }
        auto ptr = getContainerUC.execute(id);
        if (ptr is null) { writeError(res, "container not found", HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(toContainerView(*ptr)), HTTPStatus.ok);
    }

    void deleteContainer(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/containers/");
        if (id.length == 0) { writeError(res, "missing container id", HTTPStatus.badRequest); return; }
        try {
            deleteContainerUC.execute(id);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    // --- Orders ---

    void listOrders(HTTPServerRequest req, HTTPServerResponse res) {
        string projectId = "";
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "project_id") { projectId = kv.value; break; }
        }
        auto items = listOrdersUC.execute(projectId);
        OrderView[] views;
        foreach (ref o; items) views ~= toOrderView(o);
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void createOrder(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto meta = json["meta"];
            auto cmd = CreateOrderCommand(
                jsonString(json, "type"),
                jsonString(meta, "algorithm"),
                jsonUint(meta, "bit_length"),
                jsonString(meta, "mode"),
                jsonString(meta, "payload_content_type"),
                jsonString(meta, "expiration"),
                jsonString(meta, "name"),
                jsonString(json, "project_id")
            );
            auto created = createOrderUC.execute(cmd);
            writeJson(res, serializeToJsonString(toOrderView(created)), HTTPStatus.accepted);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getOrder(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/orders/");
        if (id.length == 0) { writeError(res, "missing order id", HTTPStatus.badRequest); return; }
        auto ptr = getOrderUC.execute(id);
        if (ptr is null) { writeError(res, "order not found", HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(toOrderView(*ptr)), HTTPStatus.ok);
    }

    void deleteOrder(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/orders/");
        if (id.length == 0) { writeError(res, "missing order id", HTTPStatus.badRequest); return; }
        try {
            deleteOrderUC.execute(id);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    // --- Helpers ---

    private string extractId(string path, string prefix) {
        if (path.startsWith(prefix) && path.length > prefix.length) {
            auto rest = path[prefix.length .. $];
            auto parts = rest.split("/");
            if (parts.length > 0 && parts[0].length > 0)
                return parts[0];
        }
        return "";
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, string msg, HTTPStatus status) {
        writeJson(res, `{"error":"` ~ msg ~ `"}`, status);
    }

    private string jsonString(Json json, string key) {
        if (json.type != Json.Type.object) return "";
        auto v = json[key];
        if (v.type == Json.Type.string) return v.get!string;
        return "";
    }

    private uint jsonUint(Json json, string key) {
        if (json.type != Json.Type.object) return 0;
        auto v = json[key];
        if (v.type == Json.Type.int_) return cast(uint) v.get!long;
        return 0;
    }

    private SecretView toSecretView(in Secret s) {
        return SecretView(
            s.id, s.name,
            s.secretType.to!string,
            s.algorithm.to!string,
            s.bitLength, s.mode,
            s.payloadContentType,
            s.expiration,
            s.status.to!string,
            s.createdAt, s.updatedAt,
            s.projectId,
            s.hasPayload()
        );
    }

    private ContainerView toContainerView(in SecretContainer c) {
        SecretRefView[] refs;
        foreach (ref r; c.secretRefs)
            refs ~= SecretRefView(r.name, r.secretId);
        return ContainerView(
            c.id, c.name,
            c.containerType.to!string,
            refs,
            c.createdAt, c.updatedAt,
            c.projectId
        );
    }

    private OrderView toOrderView(in Order o) {
        auto meta = OrderMetaView(
            o.meta.algorithm,
            o.meta.bitLength,
            o.meta.mode,
            o.meta.payloadContentType,
            o.meta.expiration,
            o.meta.name
        );
        return OrderView(
            o.id,
            o.orderType.to!string,
            o.status.to!string,
            meta,
            o.secretRef,
            o.createdAt, o.updatedAt,
            o.projectId,
            o.errorStatusCode,
            o.errorReason
        );
    }
}
