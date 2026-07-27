/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.application.usecases.endpoint_usecases;

import std.algorithm.searching : canFind;
import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.archer.application.dto.commands :
    CreateEndpointCommand,
    UpdateEndpointCommand;
import uim.infrastructure.archer.domain.entities.service : ArcherService;
import uim.infrastructure.archer.domain.entities.endpoint :
    ArcherEndpoint,
    EndpointTarget,
    EndpointStatus;
import uim.infrastructure.archer.domain.ports.repositories.service : IServiceRepository;
import uim.infrastructure.archer.domain.ports.repositories.endpoint : IEndpointRepository;

class CreateEndpointUseCase {
    private IServiceRepository serviceRepository;
    private IEndpointRepository endpointRepository;

    this(IServiceRepository serviceRepository, IEndpointRepository endpointRepository) {
        this.serviceRepository = serviceRepository;
        this.endpointRepository = endpointRepository;
    }

    ArcherEndpoint execute(in CreateEndpointCommand cmd) {
        auto servicePtr = serviceRepository.findById(cmd.serviceId);
        enforce(servicePtr !is null, "service not found");

        auto service = *servicePtr;
        enforce(cmd.target.network.length > 0 || cmd.target.subnet.length > 0 || cmd.target.port.length > 0,
                "target must define at least one of network, subnet or port");

        auto now = Clock.currTime.toISOExtString();
        auto endpoint = ArcherEndpoint(
            randomUUID().toString(),
            cmd.serviceId,
            cmd.name,
            cmd.description,
            EndpointTarget(cmd.target.network, cmd.target.subnet, cmd.target.port),
            firstAddress(service),
            cmd.tags.dup,
            service.requireApproval ? EndpointStatus.pending : EndpointStatus.available,
            cmd.connectionMirroring,
            now,
            now,
            cmd.projectId
        );

        endpointRepository.save(endpoint);
        return endpoint;
    }
}

class ListEndpointsUseCase {
    private IEndpointRepository repository;

    this(IEndpointRepository repository) {
        this.repository = repository;
    }

    ArcherEndpoint[] execute(
        string projectId,
        string[] tags,
        string[] tagsAny,
        string[] notTags,
        string[] notTagsAny,
        string serviceId = ""
    ) {
        ArcherEndpoint[] result;
        foreach (endpoint; repository.list()) {
            if (serviceId.length > 0 && endpoint.serviceId != serviceId) continue;
            if (projectId.length > 0 && endpoint.projectId != projectId) continue;
            if (!matchesTags(endpoint.tags, tags, tagsAny, notTags, notTagsAny)) continue;
            result ~= endpoint;
        }
        return result;
    }
}

class GetEndpointUseCase {
    private IEndpointRepository repository;

    this(IEndpointRepository repository) {
        this.repository = repository;
    }

    ArcherEndpoint* execute(string id) {
        return repository.findById(id);
    }
}

class UpdateEndpointUseCase {
    private IEndpointRepository repository;

    this(IEndpointRepository repository) {
        this.repository = repository;
    }

    ArcherEndpoint execute(in UpdateEndpointCommand cmd) {
        auto ptr = repository.findById(cmd.endpointId);
        enforce(ptr !is null, "endpoint not found");

        auto endpoint = *ptr;
        if (cmd.hasName) endpoint.name = cmd.name;
        if (cmd.hasDescription) endpoint.description = cmd.description;
        if (cmd.hasTags) endpoint.tags = cmd.tags.dup;
        if (cmd.hasConnectionMirroring) endpoint.connectionMirroring = cmd.connectionMirroring;
        endpoint.updatedAt = Clock.currTime.toISOExtString();

        repository.save(endpoint);
        return endpoint;
    }
}

class DeleteEndpointUseCase {
    private IEndpointRepository repository;

    this(IEndpointRepository repository) {
        this.repository = repository;
    }

    void execute(string endpointId) {
        auto ptr = repository.findById(endpointId);
        enforce(ptr !is null, "endpoint not found");
        repository.remove(endpointId);
    }
}

private string firstAddress(in ArcherService service) {
    if (service.ipAddresses.length > 0) return service.ipAddresses[0];
    return "0.0.0.0";
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
