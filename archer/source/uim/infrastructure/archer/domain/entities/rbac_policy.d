/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
