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
