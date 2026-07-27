/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.application.usecases.service_usecases;

import std.algorithm.searching : canFind;
import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.archer.application.dto.commands :
    CreateServiceCommand,
    UpdateServiceCommand,
    MigrateServiceCommand,
    DecideEndpointsCommand;
import uim.infrastructure.archer.domain.entities.service :
    ArcherService,
    ServiceStatus,
    parseServiceVisibility,
    parseServiceProvider,
    parseServiceProtocol;
import uim.infrastructure.archer.domain.entities.endpoint : ArcherEndpoint, EndpointStatus;
import uim.infrastructure.archer.domain.ports.repositories.service : IServiceRepository;
import uim.infrastructure.archer.domain.ports.repositories.endpoint : IEndpointRepository;

class CreateServiceUseCase {
    private IServiceRepository repository;

    this(IServiceRepository repository) {
        this.repository = repository;
    }

    ArcherService execute(in CreateServiceCommand cmd) {
        enforce(cmd.name.length > 0, "name must not be empty");
        enforce(cmd.ports.length > 0, "ports must not be empty");
        enforce(cmd.ipAddresses.length > 0, "ip_addresses must not be empty");

        auto now = Clock.currTime.toISOExtString();
        auto service = ArcherService(
            randomUUID().toString(),
            cmd.enabled,
            cmd.name,
            cmd.description,
            cmd.ports.dup,
            cmd.networkId,
            cmd.ipAddresses.dup,
            ServiceStatus.available,
            cmd.requireApproval,
            parseServiceVisibility(cmd.visibility),
            cmd.availabilityZone,
            "agent-auto-01",
            cmd.proxyProtocol,
            cmd.tags.dup,
            parseServiceProvider(cmd.provider),
            parseServiceProtocol(cmd.protocol),
            now,
            now,
            cmd.projectId,
            "ONLINE"
        );

        repository.save(service);
        return service;
    }
}

class ListServicesUseCase {
    private IServiceRepository repository;

    this(IServiceRepository repository) {
        this.repository = repository;
    }

    ArcherService[] execute(
        string projectId,
        string[] tags,
        string[] tagsAny,
        string[] notTags,
        string[] notTagsAny
    ) {
        ArcherService[] result;
        foreach (service; repository.list()) {
            if (projectId.length > 0 && service.projectId != projectId) continue;
            if (!matchesTags(service.tags, tags, tagsAny, notTags, notTagsAny)) continue;
            result ~= service;
        }
        return result;
    }
}

class GetServiceUseCase {
    private IServiceRepository repository;

    this(IServiceRepository repository) {
        this.repository = repository;
    }

    ArcherService* execute(string id) {
        return repository.findById(id);
    }
}

class UpdateServiceUseCase {
    private IServiceRepository repository;

    this(IServiceRepository repository) {
        this.repository = repository;
    }

    ArcherService execute(in UpdateServiceCommand cmd) {
        auto ptr = repository.findById(cmd.serviceId);
        enforce(ptr !is null, "service not found");

        auto service = *ptr;
        if (cmd.hasEnabled) service.enabled = cmd.enabled;
        if (cmd.hasName) service.name = cmd.name;
        if (cmd.hasDescription) service.description = cmd.description;
        if (cmd.hasPorts) service.ports = cmd.ports.dup;
        if (cmd.hasIpAddresses) service.ipAddresses = cmd.ipAddresses.dup;
        if (cmd.hasRequireApproval) service.requireApproval = cmd.requireApproval;
        if (cmd.hasVisibility) service.visibility = parseServiceVisibility(cmd.visibility);
        if (cmd.hasProxyProtocol) service.proxyProtocol = cmd.proxyProtocol;
        if (cmd.hasTags) service.tags = cmd.tags.dup;
        if (cmd.hasProtocol) service.protocol = parseServiceProtocol(cmd.protocol);
        service.updatedAt = Clock.currTime.toISOExtString();

        repository.save(service);
        return service;
    }
}

class DeleteServiceUseCase {
    private IServiceRepository serviceRepository;
    private IEndpointRepository endpointRepository;

    this(IServiceRepository serviceRepository, IEndpointRepository endpointRepository) {
        this.serviceRepository = serviceRepository;
        this.endpointRepository = endpointRepository;
    }

    void execute(string serviceId, bool cascade) {
        auto ptr = serviceRepository.findById(serviceId);
        enforce(ptr !is null, "service not found");

        auto attachedEndpoints = endpointRepository.listByService(serviceId);
        enforce(cascade || attachedEndpoints.length == 0,
                "service has active endpoints; set cascade=true to delete");

        endpointRepository.removeByService(serviceId);
        serviceRepository.remove(serviceId);
    }
}

class MigrateServiceUseCase {
    private IServiceRepository repository;

    this(IServiceRepository repository) {
        this.repository = repository;
    }

    ArcherService execute(in MigrateServiceCommand cmd) {
        auto ptr = repository.findById(cmd.serviceId);
        enforce(ptr !is null, "service not found");

        auto service = *ptr;
        service.host = cmd.targetHost.length > 0 ? cmd.targetHost : "agent-auto-02";
        service.status = ServiceStatus.pending;
        service.updatedAt = Clock.currTime.toISOExtString();
        repository.save(service);

        service.status = ServiceStatus.available;
        service.updatedAt = Clock.currTime.toISOExtString();
        repository.save(service);

        return service;
    }
}

class ListServiceEndpointsUseCase {
    private IServiceRepository serviceRepository;
    private IEndpointRepository endpointRepository;

    this(IServiceRepository serviceRepository, IEndpointRepository endpointRepository) {
        this.serviceRepository = serviceRepository;
        this.endpointRepository = endpointRepository;
    }

    ArcherEndpoint[] execute(string serviceId) {
        enforce(serviceRepository.findById(serviceId) !is null, "service not found");
        return endpointRepository.listByService(serviceId);
    }
}

class DecideServiceEndpointsUseCase {
    private IServiceRepository serviceRepository;
    private IEndpointRepository endpointRepository;

    this(IServiceRepository serviceRepository, IEndpointRepository endpointRepository) {
        this.serviceRepository = serviceRepository;
        this.endpointRepository = endpointRepository;
    }

    ArcherEndpoint[] execute(in DecideEndpointsCommand cmd, bool accept) {
        enforce(serviceRepository.findById(cmd.serviceId) !is null, "service not found");
        enforce(cmd.endpointIds.length > 0 || cmd.projectIds.length > 0,
                "must declare at least one endpoint_id or project_id");

        ArcherEndpoint[] changed;
        foreach (endpoint; endpointRepository.listByService(cmd.serviceId)) {
            if (!matchesEndpoint(endpoint, cmd.endpointIds, cmd.projectIds)) {
                continue;
            }

            endpoint.status = accept ? EndpointStatus.available : EndpointStatus.rejected;
            endpoint.updatedAt = Clock.currTime.toISOExtString();
            endpointRepository.save(endpoint);
            changed ~= endpoint;
        }
        return changed;
    }
}

private bool matchesEndpoint(in ArcherEndpoint endpoint, const(string)[] endpointIds, const(string)[] projectIds) {
    if (endpointIds.length > 0 && canFind(endpointIds, endpoint.id)) {
        return true;
    }
    if (projectIds.length > 0 && canFind(projectIds, endpoint.projectId)) {
        return true;
    }
    return false;
}

private bool matchesTags(
    string[] candidate,
    string[] tags,
    string[] tagsAny,
    string[] notTags,
    string[] notTagsAny
) {
    foreach (tag; tags) {
        if (!canFind(candidate, tag)) return false;
    }

    if (tagsAny.length > 0) {
        bool anyMatched = false;
        foreach (tag; tagsAny) {
            if (canFind(candidate, tag)) {
                anyMatched = true;
                break;
            }
        }
        if (!anyMatched) return false;
    }

    foreach (tag; notTags) {
        if (canFind(candidate, tag)) return false;
    }

    if (notTagsAny.length > 0) {
        bool hasMissingTag = false;
        foreach (tag; notTagsAny) {
            if (!canFind(candidate, tag)) {
                hasMissingTag = true;
                break;
            }
        }
        if (!hasMissingTag) return false;
    }

    return true;
}

private void enforce(bool condition, string message) {
    if (!condition) {
        throw new Exception(message);
    }
}
