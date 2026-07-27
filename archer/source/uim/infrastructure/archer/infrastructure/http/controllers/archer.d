/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.infrastructure.http.controllers.archer;

import uim.infrastructure.archer.application.dto.commands;
import uim.infrastructure.archer.application.usecases.service_usecases :
    CreateServiceUseCase,
    ListServicesUseCase,
    GetServiceUseCase,
    UpdateServiceUseCase,
    DeleteServiceUseCase,
    MigrateServiceUseCase,
    ListServiceEndpointsUseCase,
    DecideServiceEndpointsUseCase;
import uim.infrastructure.archer.application.usecases.endpoint_usecases :
    CreateEndpointUseCase,
    ListEndpointsUseCase,
    GetEndpointUseCase,
    UpdateEndpointUseCase,
    DeleteEndpointUseCase;
import uim.infrastructure.archer.application.usecases.rbac_usecases :
    CreateRbacPolicyUseCase,
    ListRbacPoliciesUseCase,
    GetRbacPolicyUseCase,
    UpdateRbacPolicyUseCase,
    DeleteRbacPolicyUseCase;
import uim.infrastructure.archer.application.usecases.quota_usecases :
    ListQuotasUseCase,
    GetQuotaUseCase,
    GetQuotaDefaultsUseCase,
    UpdateQuotaUseCase,
    DeleteQuotaUseCase;
import uim.infrastructure.archer.application.usecases.agent_usecases :
    ListAgentsUseCase,
    GetAgentUseCase;
import uim.infrastructure.archer.domain.entities.service :
    ArcherService,
    visibilityToString,
    providerToString,
    protocolToString,
    serviceStatusToString;
import uim.infrastructure.archer.domain.entities.endpoint :
    ArcherEndpoint,
    endpointStatusToString;
import uim.infrastructure.archer.domain.entities.rbac_policy :
    ArcherRbacPolicy,
    rbacTargetTypeToString;
import uim.infrastructure.archer.domain.entities.quota :
    ArcherQuota,
    ArcherQuotaDefaults;
import uim.infrastructure.archer.domain.entities.agent :
    ArcherAgent,
    agentProviderToString;
import std.conv : to;
import std.string : split, startsWith, toLower;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;

struct LinkView {
    string rel;
    string href;
}

struct CollectionView(T) {
    LinkView[] links;
    T[] items;
}

struct ServiceView {
    string id;
    bool enabled;
    string name;
    string description;
    ushort[] ports;
    string network_id;
    string[] ip_addresses;
    string status;
    bool require_approval;
    string visibility;
    string availability_zone;
    string host;
    bool proxy_protocol;
    string[] tags;
    string provider;
    string protocol;
    string created_at;
    string updated_at;
    string project_id;
    string health_status;
}

struct EndpointTargetView {
    string network;
    string subnet;
    string port;
}

struct EndpointView {
    string id;
    string service_id;
    string name;
    string description;
    EndpointTargetView target;
    string ip_address;
    string[] tags;
    string status;
    bool connection_mirroring;
    string created_at;
    string updated_at;
    string project_id;
}

struct EndpointDecisionView {
    string id;
    string status;
    string project_id;
}

struct ErrorView {
    int code;
    string message;
}

struct RbacPolicyView {
    string id;
    string target_type;
    string target;
    string service_id;
    string created_at;
    string updated_at;
    string project_id;
}

struct QuotaView {
    int service;
    int endpoint;
    int in_use_service;
    int in_use_endpoint;
    string project_id;
}

struct QuotaDefaultsPayloadView {
    int service;
    int endpoint;
}

struct QuotaDefaultsEnvelopeView {
    QuotaDefaultsPayloadView quota;
}

struct AgentView {
    string host;
    string availability_zone;
    string provider;
    bool enabled;
    string physnet;
    string created_at;
    string updated_at;
    string heartbeat_at;
    int services;
}

class ArcherController {
    private CreateServiceUseCase createServiceUC;
    private ListServicesUseCase listServicesUC;
    private GetServiceUseCase getServiceUC;
    private UpdateServiceUseCase updateServiceUC;
    private DeleteServiceUseCase deleteServiceUC;
    private MigrateServiceUseCase migrateServiceUC;
    private ListServiceEndpointsUseCase listServiceEndpointsUC;
    private DecideServiceEndpointsUseCase decideServiceEndpointsUC;

    private CreateEndpointUseCase createEndpointUC;
    private ListEndpointsUseCase listEndpointsUC;
    private GetEndpointUseCase getEndpointUC;
    private UpdateEndpointUseCase updateEndpointUC;
    private DeleteEndpointUseCase deleteEndpointUC;

    private CreateRbacPolicyUseCase createRbacPolicyUC;
    private ListRbacPoliciesUseCase listRbacPoliciesUC;
    private GetRbacPolicyUseCase getRbacPolicyUC;
    private UpdateRbacPolicyUseCase updateRbacPolicyUC;
    private DeleteRbacPolicyUseCase deleteRbacPolicyUC;

    private ListQuotasUseCase listQuotasUC;
    private GetQuotaUseCase getQuotaUC;
    private GetQuotaDefaultsUseCase getQuotaDefaultsUC;
    private UpdateQuotaUseCase updateQuotaUC;
    private DeleteQuotaUseCase deleteQuotaUC;

    private ListAgentsUseCase listAgentsUC;
    private GetAgentUseCase getAgentUC;

    this(
        CreateServiceUseCase createServiceUC,
        ListServicesUseCase listServicesUC,
        GetServiceUseCase getServiceUC,
        UpdateServiceUseCase updateServiceUC,
        DeleteServiceUseCase deleteServiceUC,
        MigrateServiceUseCase migrateServiceUC,
        ListServiceEndpointsUseCase listServiceEndpointsUC,
        DecideServiceEndpointsUseCase decideServiceEndpointsUC,
        CreateEndpointUseCase createEndpointUC,
        ListEndpointsUseCase listEndpointsUC,
        GetEndpointUseCase getEndpointUC,
        UpdateEndpointUseCase updateEndpointUC,
        DeleteEndpointUseCase deleteEndpointUC,
        CreateRbacPolicyUseCase createRbacPolicyUC,
        ListRbacPoliciesUseCase listRbacPoliciesUC,
        GetRbacPolicyUseCase getRbacPolicyUC,
        UpdateRbacPolicyUseCase updateRbacPolicyUC,
        DeleteRbacPolicyUseCase deleteRbacPolicyUC,
        ListQuotasUseCase listQuotasUC,
        GetQuotaUseCase getQuotaUC,
        GetQuotaDefaultsUseCase getQuotaDefaultsUC,
        UpdateQuotaUseCase updateQuotaUC,
        DeleteQuotaUseCase deleteQuotaUC,
        ListAgentsUseCase listAgentsUC,
        GetAgentUseCase getAgentUC
    ) {
        this.createServiceUC = createServiceUC;
        this.listServicesUC = listServicesUC;
        this.getServiceUC = getServiceUC;
        this.updateServiceUC = updateServiceUC;
        this.deleteServiceUC = deleteServiceUC;
        this.migrateServiceUC = migrateServiceUC;
        this.listServiceEndpointsUC = listServiceEndpointsUC;
        this.decideServiceEndpointsUC = decideServiceEndpointsUC;

        this.createEndpointUC = createEndpointUC;
        this.listEndpointsUC = listEndpointsUC;
        this.getEndpointUC = getEndpointUC;
        this.updateEndpointUC = updateEndpointUC;
        this.deleteEndpointUC = deleteEndpointUC;

        this.createRbacPolicyUC = createRbacPolicyUC;
        this.listRbacPoliciesUC = listRbacPoliciesUC;
        this.getRbacPolicyUC = getRbacPolicyUC;
        this.updateRbacPolicyUC = updateRbacPolicyUC;
        this.deleteRbacPolicyUC = deleteRbacPolicyUC;

        this.listQuotasUC = listQuotasUC;
        this.getQuotaUC = getQuotaUC;
        this.getQuotaDefaultsUC = getQuotaDefaultsUC;
        this.updateQuotaUC = updateQuotaUC;
        this.deleteQuotaUC = deleteQuotaUC;

        this.listAgentsUC = listAgentsUC;
        this.getAgentUC = getAgentUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &versionInfo);
        router.get("/health", &health);

        router.get("/service", &listServices);
        router.post("/service", &createService);
        router.get("/service/*", &getServiceRoutes);
        router.put("/service/*", &putServiceRoutes);
        router.delete_("/service/*", &deleteService);

        router.get("/endpoint", &listEndpoints);
        router.post("/endpoint", &createEndpoint);
        router.get("/endpoint/*", &getEndpoint);
        router.put("/endpoint/*", &updateEndpoint);
        router.delete_("/endpoint/*", &deleteEndpoint);

        router.get("/rbac-policies", &listRbacPolicies);
        router.post("/rbac-policies", &createRbacPolicy);
        router.get("/rbac-policies/*", &getRbacPolicy);
        router.put("/rbac-policies/*", &updateRbacPolicy);
        router.delete_("/rbac-policies/*", &deleteRbacPolicy);

        router.get("/quotas/defaults", &getQuotaDefaults);
        router.get("/quotas", &listQuotas);
        router.get("/quotas/*", &getQuota);
        router.put("/quotas/*", &putQuota);
        router.delete_("/quotas/*", &deleteQuota);

        router.get("/agents", &listAgents);
        router.get("/agents/*", &getAgent);
    }

    void versionInfo(HTTPServerRequest req, HTTPServerResponse res) {
        auto payload = `{"versions":[{"id":"v1","status":"stable","links":[{"rel":"self","href":"/"}]}],"updated":"2026-06-01T00:00:00Z","version":"1.0.0","links":[{"rel":"self","href":"/"}],"capabilities":["pagination","sort","tags"]}`;
        writeJson(res, payload, HTTPStatus.ok);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok","service":"uim-archer-service"}`, HTTPStatus.ok);
    }

    void listServices(HTTPServerRequest req, HTTPServerResponse res) {
        auto projectId = queryValue(req, "project_id");
        auto tags = queryCsv(req, "tags");
        auto tagsAny = queryCsv(req, "tags-any");
        auto notTags = queryCsv(req, "not-tags");
        auto notTagsAny = queryCsv(req, "not-tags-any");

        auto list = listServicesUC.execute(projectId, tags, tagsAny, notTags, notTagsAny);
        ServiceView[] items;
        foreach (service; list) {
            items ~= toServiceView(service);
        }

        auto payload = CollectionView!ServiceView([], items);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void createService(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateServiceCommand(
                jsonBool(json, "enabled", true),
                jsonString(json, "name"),
                jsonString(json, "description"),
                jsonUshortArray(json, "ports"),
                jsonString(json, "network_id"),
                jsonStringArray(json, "ip_addresses"),
                jsonBool(json, "require_approval", false),
                jsonString(json, "visibility", "private"),
                jsonString(json, "availability_zone"),
                jsonBool(json, "proxy_protocol", true),
                jsonStringArray(json, "tags"),
                jsonString(json, "provider", "tenant"),
                jsonString(json, "protocol", "HTTP"),
                jsonString(json, "project_id")
            );
            auto created = createServiceUC.execute(cmd);
            writeJson(res, serializeToJsonString(toServiceView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getServiceRoutes(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/service/");
        if (parts.length == 1) {
            getService(parts[0], res);
            return;
        }
        if (parts.length == 2 && parts[1] == "endpoints") {
            listServiceEndpoints(parts[0], res);
            return;
        }

        writeError(res, "unsupported service route", HTTPStatus.badRequest);
    }

    void putServiceRoutes(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/service/");
        if (parts.length == 1) {
            updateService(parts[0], req, res);
            return;
        }
        if (parts.length == 2 && parts[1] == "accept_endpoints") {
            decideServiceEndpoints(parts[0], req, res, true);
            return;
        }
        if (parts.length == 2 && parts[1] == "reject_endpoints") {
            decideServiceEndpoints(parts[0], req, res, false);
            return;
        }

        writeError(res, "unsupported service route", HTTPStatus.badRequest);
    }

    void getService(string id, HTTPServerResponse res) {
        auto ptr = getServiceUC.execute(id);
        if (ptr is null) {
            writeError(res, "service not found", HTTPStatus.notFound);
            return;
        }
        writeJson(res, serializeToJsonString(toServiceView(*ptr)), HTTPStatus.ok);
    }

    void updateService(string id, HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            UpdateServiceCommand cmd;
            cmd.serviceId = id;

            if (hasValue(json, "enabled")) {
                cmd.hasEnabled = true;
                cmd.enabled = jsonBool(json, "enabled", false);
            }
            if (hasValue(json, "name")) {
                cmd.hasName = true;
                cmd.name = jsonString(json, "name");
            }
            if (hasValue(json, "description")) {
                cmd.hasDescription = true;
                cmd.description = jsonString(json, "description");
            }
            if (hasValue(json, "ports")) {
                cmd.hasPorts = true;
                cmd.ports = jsonUshortArray(json, "ports");
            }
            if (hasValue(json, "ip_addresses")) {
                cmd.hasIpAddresses = true;
                cmd.ipAddresses = jsonStringArray(json, "ip_addresses");
            }
            if (hasValue(json, "require_approval")) {
                cmd.hasRequireApproval = true;
                cmd.requireApproval = jsonBool(json, "require_approval", false);
            }
            if (hasValue(json, "visibility")) {
                cmd.hasVisibility = true;
                cmd.visibility = jsonString(json, "visibility");
            }
            if (hasValue(json, "proxy_protocol")) {
                cmd.hasProxyProtocol = true;
                cmd.proxyProtocol = jsonBool(json, "proxy_protocol", true);
            }
            if (hasValue(json, "tags")) {
                cmd.hasTags = true;
                cmd.tags = jsonStringArray(json, "tags");
            }
            if (hasValue(json, "protocol")) {
                cmd.hasProtocol = true;
                cmd.protocol = jsonString(json, "protocol");
            }

            auto updated = updateServiceUC.execute(cmd);
            writeJson(res, serializeToJsonString(toServiceView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteService(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/service/");
        if (parts.length != 1) {
            writeError(res, "unsupported service route", HTTPStatus.badRequest);
            return;
        }

        auto cascade = queryValue(req, "cascade").toLower() == "true";
        try {
            deleteServiceUC.execute(parts[0], cascade);
            res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
        } catch (Exception ex) {
            auto status = ex.msg.startsWith("service has active") ? HTTPStatus.conflict : HTTPStatus.notFound;
            writeError(res, ex.msg, status);
        }
    }

    void listServiceEndpoints(string serviceId, HTTPServerResponse res) {
        try {
            auto list = listServiceEndpointsUC.execute(serviceId);
            EndpointView[] items;
            foreach (endpoint; list) {
                items ~= toEndpointView(endpoint);
            }
            auto payload = CollectionView!EndpointView([], items);
            writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void decideServiceEndpoints(string serviceId, HTTPServerRequest req, HTTPServerResponse res, bool accept) {
        try {
            auto json = req.json;
            auto cmd = DecideEndpointsCommand(
                serviceId,
                jsonStringArray(json, "endpoint_ids"),
                jsonStringArray(json, "project_ids")
            );
            auto list = decideServiceEndpointsUC.execute(cmd, accept);
            EndpointDecisionView[] views;
            foreach (endpoint; list) {
                views ~= EndpointDecisionView(endpoint.id, endpointStatusToString(endpoint.status), endpoint.projectId);
            }
            writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
        } catch (Exception ex) {
            auto status = ex.msg.startsWith("must declare") ? HTTPStatus.badRequest : HTTPStatus.notFound;
            writeError(res, ex.msg, status);
        }
    }

    void listEndpoints(HTTPServerRequest req, HTTPServerResponse res) {
        auto projectId = queryValue(req, "project_id");
        auto tags = queryCsv(req, "tags");
        auto tagsAny = queryCsv(req, "tags-any");
        auto notTags = queryCsv(req, "not-tags");
        auto notTagsAny = queryCsv(req, "not-tags-any");

        auto list = listEndpointsUC.execute(projectId, tags, tagsAny, notTags, notTagsAny);
        EndpointView[] items;
        foreach (endpoint; list) {
            items ~= toEndpointView(endpoint);
        }

        auto payload = CollectionView!EndpointView([], items);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void createEndpoint(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto target = json["target"];

            auto cmd = CreateEndpointCommand(
                jsonString(json, "service_id"),
                jsonString(json, "name"),
                jsonString(json, "description"),
                EndpointTargetCommand(
                    jsonString(target, "network"),
                    jsonString(target, "subnet"),
                    jsonString(target, "port")
                ),
                jsonStringArray(json, "tags"),
                jsonBool(json, "connection_mirroring", false),
                jsonString(json, "project_id")
            );

            auto created = createEndpointUC.execute(cmd);
            writeJson(res, serializeToJsonString(toEndpointView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getEndpoint(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/endpoint/");
        if (parts.length != 1) {
            writeError(res, "unsupported endpoint route", HTTPStatus.badRequest);
            return;
        }

        auto ptr = getEndpointUC.execute(parts[0]);
        if (ptr is null) {
            writeError(res, "endpoint not found", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toEndpointView(*ptr)), HTTPStatus.ok);
    }

    void updateEndpoint(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/endpoint/");
        if (parts.length != 1) {
            writeError(res, "unsupported endpoint route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            UpdateEndpointCommand cmd;
            cmd.endpointId = parts[0];

            if (hasValue(json, "name")) {
                cmd.hasName = true;
                cmd.name = jsonString(json, "name");
            }
            if (hasValue(json, "description")) {
                cmd.hasDescription = true;
                cmd.description = jsonString(json, "description");
            }
            if (hasValue(json, "tags")) {
                cmd.hasTags = true;
                cmd.tags = jsonStringArray(json, "tags");
            }
            if (hasValue(json, "connection_mirroring")) {
                cmd.hasConnectionMirroring = true;
                cmd.connectionMirroring = jsonBool(json, "connection_mirroring", false);
            }

            auto updated = updateEndpointUC.execute(cmd);
            writeJson(res, serializeToJsonString(toEndpointView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteEndpoint(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/endpoint/");
        if (parts.length != 1) {
            writeError(res, "unsupported endpoint route", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteEndpointUC.execute(parts[0]);
            res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void listRbacPolicies(HTTPServerRequest req, HTTPServerResponse res) {
        RbacPolicyView[] items;
        foreach (policy; listRbacPoliciesUC.execute()) {
            items ~= toRbacPolicyView(policy);
        }
        auto payload = CollectionView!RbacPolicyView([], items);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void createRbacPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateRbacPolicyCommand(
                jsonString(json, "service_id"),
                jsonString(json, "target"),
                jsonString(json, "project_id")
            );
            auto created = createRbacPolicyUC.execute(cmd);
            writeJson(res, serializeToJsonString(toRbacPolicyView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getRbacPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/rbac-policies/");
        if (parts.length != 1) {
            writeError(res, "unsupported rbac route", HTTPStatus.badRequest);
            return;
        }

        auto ptr = getRbacPolicyUC.execute(parts[0]);
        if (ptr is null) {
            writeError(res, "rbac policy not found", HTTPStatus.notFound);
            return;
        }
        writeJson(res, serializeToJsonString(toRbacPolicyView(*ptr)), HTTPStatus.ok);
    }

    void updateRbacPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/rbac-policies/");
        if (parts.length != 1) {
            writeError(res, "unsupported rbac route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            UpdateRbacPolicyCommand cmd;
            cmd.policyId = parts[0];
            if (hasValue(json, "target")) {
                cmd.hasTarget = true;
                cmd.target = jsonString(json, "target");
            }
            if (hasValue(json, "project_id")) {
                cmd.hasProjectId = true;
                cmd.projectId = jsonString(json, "project_id");
            }
            auto updated = updateRbacPolicyUC.execute(cmd);
            writeJson(res, serializeToJsonString(toRbacPolicyView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteRbacPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/rbac-policies/");
        if (parts.length != 1) {
            writeError(res, "unsupported rbac route", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteRbacPolicyUC.execute(parts[0]);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void listQuotas(HTTPServerRequest req, HTTPServerResponse res) {
        auto projectId = queryValue(req, "project_id");
        QuotaView[] items;
        foreach (quota; listQuotasUC.execute(projectId)) {
            items ~= toQuotaView(quota);
        }
        auto payload = CollectionView!QuotaView([], items);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void getQuotaDefaults(HTTPServerRequest req, HTTPServerResponse res) {
        auto defaults = getQuotaDefaultsUC.execute();
        writeJson(res, serializeToJsonString(QuotaDefaultsEnvelopeView(QuotaDefaultsPayloadView(defaults.service, defaults.endpoint))), HTTPStatus.ok);
    }

    void getQuota(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/quotas/");
        if (parts.length != 1 || parts[0] == "defaults") {
            writeError(res, "unsupported quota route", HTTPStatus.badRequest);
            return;
        }

        auto quota = getQuotaUC.execute(parts[0]);
        writeJson(res, serializeToJsonString(toQuotaView(quota)), HTTPStatus.ok);
    }

    void putQuota(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/quotas/");
        if (parts.length != 1 || parts[0] == "defaults") {
            writeError(res, "unsupported quota route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            auto cmd = UpdateQuotaCommand(
                parts[0],
                hasValue(json, "service"),
                jsonInt(json, "service", 0),
                hasValue(json, "endpoint"),
                jsonInt(json, "endpoint", 0)
            );
            auto updated = updateQuotaUC.execute(cmd);
            writeJson(res, serializeToJsonString(toQuotaView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteQuota(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/quotas/");
        if (parts.length != 1 || parts[0] == "defaults") {
            writeError(res, "unsupported quota route", HTTPStatus.badRequest);
            return;
        }

        deleteQuotaUC.execute(parts[0]);
        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
    }

    void listAgents(HTTPServerRequest req, HTTPServerResponse res) {
        AgentView[] items;
        foreach (agent; listAgentsUC.execute()) {
            items ~= toAgentView(agent);
        }
        auto payload = CollectionView!AgentView([], items);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void getAgent(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = pathSegments(req.requestPath.to!string, "/agents/");
        if (parts.length != 1) {
            writeError(res, "unsupported agent route", HTTPStatus.badRequest);
            return;
        }

        auto ptr = getAgentUC.execute(parts[0]);
        if (ptr is null) {
            writeError(res, "agent not found", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toAgentView(*ptr)), HTTPStatus.ok);
    }

    private string queryValue(HTTPServerRequest req, string key) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == key) {
                return kv.value;
            }
        }
        return "";
    }

    private string[] queryCsv(HTTPServerRequest req, string key) {
        auto value = queryValue(req, key);
        if (value.length == 0) {
            return [];
        }

        string[] items;
        foreach (raw; value.split(",")) {
            if (raw.length > 0) {
                items ~= raw;
            }
        }
        return items;
    }

    private string[] pathSegments(string path, string prefix) {
        if (!path.startsWith(prefix)) {
            return [];
        }

        auto rest = path[prefix.length .. $];
        string[] segments;
        foreach (part; rest.split("/")) {
            if (part.length > 0) {
                segments ~= part;
            }
        }
        return segments;
    }

    private bool hasValue(Json obj, string key) {
        auto value = obj[key];
        return value.type != Json.Type.undefined && value.type != Json.Type.null_;
    }

    private string jsonString(Json obj, string key, string fallback = "") {
        auto value = obj[key];
        if (value.type == Json.Type.undefined || value.type == Json.Type.null_) {
            return fallback;
        }
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        if (value.type == Json.Type.bool_) {
            return value.get!bool ? "true" : "false";
        }
        if (value.type == Json.Type.int_ || value.type == Json.Type.bigInt || value.type == Json.Type.float_) {
            return value.to!string;
        }
        return fallback;
    }

    private bool jsonBool(Json obj, string key, bool fallback) {
        auto value = obj[key];
        if (value.type == Json.Type.undefined || value.type == Json.Type.null_) {
            return fallback;
        }
        if (value.type == Json.Type.bool_) {
            return value.get!bool;
        }
        if (value.type == Json.Type.string) {
            auto normalized = value.get!string.toLower();
            return normalized == "true" || normalized == "1";
        }
        return fallback;
    }

    private int jsonInt(Json obj, string key, int fallback) {
        auto value = obj[key];
        if (value.type == Json.Type.undefined || value.type == Json.Type.null_) {
            return fallback;
        }
        if (value.type == Json.Type.int_ || value.type == Json.Type.bigInt) {
            return cast(int) value.get!long;
        }
        if (value.type == Json.Type.string) {
            return value.get!string.to!int;
        }
        return fallback;
    }

    private ushort[] jsonUshortArray(Json obj, string key) {
        auto value = obj[key];
        if (value.type != Json.Type.array) {
            return [];
        }

        ushort[] result;
        foreach (item; value.byValue()) {
            if (item.type == Json.Type.int_ || item.type == Json.Type.bigInt) {
                result ~= cast(ushort) item.get!long;
                continue;
            }
            if (item.type == Json.Type.string) {
                result ~= item.get!string.to!ushort;
            }
        }
        return result;
    }

    private string[] jsonStringArray(Json obj, string key) {
        auto value = obj[key];
        if (value.type != Json.Type.array) {
            return [];
        }

        string[] result;
        foreach (item; value.byValue()) {
            if (item.type == Json.Type.string) {
                result ~= item.get!string;
            }
        }
        return result;
    }

    private ServiceView toServiceView(in ArcherService service) {
        return ServiceView(
            service.id,
            service.enabled,
            service.name,
            service.description,
            service.ports.dup,
            service.networkId,
            service.ipAddresses.dup,
            serviceStatusToString(service.status),
            service.requireApproval,
            visibilityToString(service.visibility),
            service.availabilityZone,
            service.host,
            service.proxyProtocol,
            service.tags.dup,
            providerToString(service.provider),
            protocolToString(service.protocol),
            service.createdAt,
            service.updatedAt,
            service.projectId,
            service.healthStatus
        );
    }

    private EndpointView toEndpointView(in ArcherEndpoint endpoint) {
        return EndpointView(
            endpoint.id,
            endpoint.serviceId,
            endpoint.name,
            endpoint.description,
            EndpointTargetView(endpoint.target.network, endpoint.target.subnet, endpoint.target.port),
            endpoint.ipAddress,
            endpoint.tags.dup,
            endpointStatusToString(endpoint.status),
            endpoint.connectionMirroring,
            endpoint.createdAt,
            endpoint.updatedAt,
            endpoint.projectId
        );
    }

    private RbacPolicyView toRbacPolicyView(in ArcherRbacPolicy policy) {
        return RbacPolicyView(
            policy.id,
            rbacTargetTypeToString(policy.targetType),
            policy.target,
            policy.serviceId,
            policy.createdAt,
            policy.updatedAt,
            policy.projectId
        );
    }

    private QuotaView toQuotaView(in ArcherQuota quota) {
        return QuotaView(
            quota.service,
            quota.endpoint,
            quota.inUseService,
            quota.inUseEndpoint,
            quota.projectId
        );
    }

    private AgentView toAgentView(in ArcherAgent agent) {
        return AgentView(
            agent.host,
            agent.availabilityZone,
            agentProviderToString(agent.provider),
            agent.enabled,
            agent.physnet,
            agent.createdAt,
            agent.updatedAt,
            agent.heartbeatAt,
            agent.services
        );
    }

    private void writeJson(HTTPServerResponse res, string payload, HTTPStatus status) {
        res.writeBody(payload, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, string message, HTTPStatus status) {
        writeJson(
            res,
            serializeToJsonString(ErrorView(cast(int) status, message)),
            status
        );
    }
}
