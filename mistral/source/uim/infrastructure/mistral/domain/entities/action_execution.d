/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.domain.entities.action_execution;

import uim.infrastructure.mistral.domain.entities.execution : ExecutionState;

struct ActionExecution {
    string id;
    string workflowName;
    string taskName;
    string taskExecutionId;
    string name;
    string description;
    string projectId;
    ExecutionState state;
    string stateInfo;
    bool accepted;
    string inputJson;
    string outputJson;
    string paramsJson;
    string createdAt;
    string updatedAt;
}
