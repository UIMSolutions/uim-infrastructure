module uim.infrastructure.archer.application.usecases.rbac_usecases;

import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.archer.application.dto.commands :
    CreateRbacPolicyCommand,
    UpdateRbacPolicyCommand;
import uim.infrastructure.archer.domain.entities.rbac_policy :
    ArcherRbacPolicy,
    RbacTargetType,
    rbacTargetTypeToString;
import uim.infrastructure.archer.domain.ports.repositories.rbac_policy : IRbacPolicyRepository;

class CreateRbacPolicyUseCase {
    private IRbacPolicyRepository repository;

    this(IRbacPolicyRepository repository) {
        this.repository = repository;
    }

    ArcherRbacPolicy execute(in CreateRbacPolicyCommand cmd) {
        enforce(cmd.serviceId.length > 0, "service_id must not be empty");
        enforce(cmd.target.length > 0, "target must not be empty");

        auto now = Clock.currTime.toISOExtString();
        auto policy = ArcherRbacPolicy(
            randomUUID().toString(),
            RbacTargetType.project,
            cmd.target,
            cmd.serviceId,
            now,
            now,
            cmd.projectId
        );
        repository.save(policy);
        return policy;
    }
}

class ListRbacPoliciesUseCase {
    private IRbacPolicyRepository repository;

    this(IRbacPolicyRepository repository) {
        this.repository = repository;
    }

    ArcherRbacPolicy[] execute() {
        return repository.list();
    }
}

class GetRbacPolicyUseCase {
    private IRbacPolicyRepository repository;

    this(IRbacPolicyRepository repository) {
        this.repository = repository;
    }

    ArcherRbacPolicy* execute(string id) {
        return repository.findById(id);
    }
}

class UpdateRbacPolicyUseCase {
    private IRbacPolicyRepository repository;

    this(IRbacPolicyRepository repository) {
        this.repository = repository;
    }

    ArcherRbacPolicy execute(in UpdateRbacPolicyCommand cmd) {
        auto ptr = repository.findById(cmd.policyId);
        enforce(ptr !is null, "rbac policy not found");

        auto policy = *ptr;
        if (cmd.hasTarget) policy.target = cmd.target;
        if (cmd.hasProjectId) policy.projectId = cmd.projectId;
        policy.updatedAt = Clock.currTime.toISOExtString();

        repository.save(policy);
        return policy;
    }
}

class DeleteRbacPolicyUseCase {
    private IRbacPolicyRepository repository;

    this(IRbacPolicyRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto ptr = repository.findById(id);
        enforce(ptr !is null, "rbac policy not found");
        repository.remove(id);
    }
}

private void enforce(bool condition, string message) {
    if (!condition) {
        throw new Exception(message);
    }
}
