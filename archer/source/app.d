/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

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
import uim.infrastructure.archer.infrastructure.http.controllers.archer : ArcherController;
import uim.infrastructure.archer.infrastructure.persistence.memory.service_repository : InMemoryServiceRepository;
import uim.infrastructure.archer.infrastructure.persistence.memory.endpoint_repository : InMemoryEndpointRepository;
import uim.infrastructure.archer.infrastructure.persistence.memory.rbac_policy_repository : InMemoryRbacPolicyRepository;
import uim.infrastructure.archer.infrastructure.persistence.memory.quota_repository : InMemoryQuotaRepository;
import uim.infrastructure.archer.infrastructure.persistence.memory.agent_repository : InMemoryAgentRepository;
import uim.infrastructure.archer.domain.entities.quota : ArcherQuotaDefaults;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto serviceRepo = new InMemoryServiceRepository();
    auto endpointRepo = new InMemoryEndpointRepository();
    auto rbacPolicyRepo = new InMemoryRbacPolicyRepository();
    auto quotaRepo = new InMemoryQuotaRepository();
    auto agentRepo = new InMemoryAgentRepository();
    auto quotaDefaults = ArcherQuotaDefaults(5, 5);

    auto createServiceUC = new CreateServiceUseCase(serviceRepo);
    auto listServicesUC = new ListServicesUseCase(serviceRepo);
    auto getServiceUC = new GetServiceUseCase(serviceRepo);
    auto updateServiceUC = new UpdateServiceUseCase(serviceRepo);
    auto deleteServiceUC = new DeleteServiceUseCase(serviceRepo, endpointRepo);
    auto migrateServiceUC = new MigrateServiceUseCase(serviceRepo);
    auto listServiceEndpointsUC = new ListServiceEndpointsUseCase(serviceRepo, endpointRepo);
    auto decideServiceEndpointsUC = new DecideServiceEndpointsUseCase(serviceRepo, endpointRepo);

    auto createEndpointUC = new CreateEndpointUseCase(serviceRepo, endpointRepo);
    auto listEndpointsUC = new ListEndpointsUseCase(endpointRepo);
    auto getEndpointUC = new GetEndpointUseCase(endpointRepo);
    auto updateEndpointUC = new UpdateEndpointUseCase(endpointRepo);
    auto deleteEndpointUC = new DeleteEndpointUseCase(endpointRepo);

    auto createRbacPolicyUC = new CreateRbacPolicyUseCase(rbacPolicyRepo);
    auto listRbacPoliciesUC = new ListRbacPoliciesUseCase(rbacPolicyRepo);
    auto getRbacPolicyUC = new GetRbacPolicyUseCase(rbacPolicyRepo);
    auto updateRbacPolicyUC = new UpdateRbacPolicyUseCase(rbacPolicyRepo);
    auto deleteRbacPolicyUC = new DeleteRbacPolicyUseCase(rbacPolicyRepo);

    auto listQuotasUC = new ListQuotasUseCase(quotaRepo);
    auto getQuotaUC = new GetQuotaUseCase(quotaRepo, quotaDefaults);
    auto getQuotaDefaultsUC = new GetQuotaDefaultsUseCase(quotaDefaults);
    auto updateQuotaUC = new UpdateQuotaUseCase(quotaRepo, quotaDefaults);
    auto deleteQuotaUC = new DeleteQuotaUseCase(quotaRepo);

    auto listAgentsUC = new ListAgentsUseCase(agentRepo);
    auto getAgentUC = new GetAgentUseCase(agentRepo);

    auto controller = new ArcherController(
        createServiceUC,
        listServicesUC,
        getServiceUC,
        updateServiceUC,
        deleteServiceUC,
        migrateServiceUC,
        listServiceEndpointsUC,
        decideServiceEndpointsUC,
        createEndpointUC,
        listEndpointsUC,
        getEndpointUC,
        updateEndpointUC,
        deleteEndpointUC,
        createRbacPolicyUC,
        listRbacPoliciesUC,
        getRbacPolicyUC,
        updateRbacPolicyUC,
        deleteRbacPolicyUC,
        listQuotasUC,
        getQuotaUC,
        getQuotaDefaultsUC,
        updateQuotaUC,
        deleteQuotaUC,
        listAgentsUC,
        getAgentUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Archer-like endpoint catalog service starting on %s:%d",
            settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) return cast(ushort) 9312;
    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 9312;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
