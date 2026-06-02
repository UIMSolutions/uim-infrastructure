module uim.infrastructure.archer.domain.entities.rbac_policy;

enum RbacTargetType {
    project
}

struct ArcherRbacPolicy {
    string id;
    RbacTargetType targetType;
    string target;
    string serviceId;
    string createdAt;
    string updatedAt;
    string projectId;
}

string rbacTargetTypeToString(RbacTargetType targetType) {
    return targetType == RbacTargetType.project ? "project" : "project";
}
