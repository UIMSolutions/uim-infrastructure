/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.domain.entities.workflow;

struct WorkflowDefinition {
    string id;
    string name;
    string namespace_;
    string definition;
    string description;
    string[] tags;
    string createdAt;
    string updatedAt;
}
