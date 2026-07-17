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
