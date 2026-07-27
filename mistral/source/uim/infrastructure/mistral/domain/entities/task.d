/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.domain.entities.task;

import uim.infrastructure.mistral.domain.entities.execution : ExecutionState;

struct TaskExecution {
    string id;
    string workflowName;
    string workflowId;
    string workflowExecutionId;
    string name;
    ExecutionState state;
    string stateInfo;
    string resultJson;
    string publishedJson;
    bool processed;
    bool reset;
    string createdAt;
    string updatedAt;
}
