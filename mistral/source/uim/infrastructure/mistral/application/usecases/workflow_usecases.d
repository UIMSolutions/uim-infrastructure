module uim.infrastructure.mistral.application.usecases.workflow_usecases;

import uim.infrastructure.mistral.domain.entities.workflow : WorkflowDefinition;
import uim.infrastructure.mistral.domain.entities.execution : WorkflowExecution;
import uim.infrastructure.mistral.domain.entities.task : TaskExecution;
import uim.infrastructure.mistral.domain.entities.action_execution : ActionExecution;
import uim.infrastructure.mistral.domain.ports.repositories.workflow_engine : IWorkflowEngineRepository;
import uim.infrastructure.mistral.application.dto.mistral_command : WorkflowCommand, UpdateWorkflowCommand, ExecutionCommand, ActionExecutionCommand;

class WorkflowUseCases {
private:
    IWorkflowEngineRepository repository;

public:
    this(IWorkflowEngineRepository repository) {
        this.repository = repository;
    }

    WorkflowDefinition[] listWorkflows() {
        return repository.listWorkflows();
    }

    WorkflowDefinition* getWorkflow(string idOrName, string namespace_ = "") {
        return repository.getWorkflow(idOrName, namespace_);
    }

    WorkflowDefinition createWorkflow(WorkflowCommand command) {
        return repository.createWorkflow(
            command.name,
            command.namespace_,
            command.definition,
            command.description,
            command.tags
        );
    }

    WorkflowDefinition* updateWorkflow(string idOrName, string namespace_, UpdateWorkflowCommand command) {
        return repository.updateWorkflow(
            idOrName,
            namespace_,
            command.name,
            command.definition,
            command.description,
            command.tags,
            command.updateName,
            command.updateDefinition,
            command.updateDescription,
            command.updateTags
        );
    }

    bool deleteWorkflow(string idOrName, string namespace_ = "") {
        return repository.deleteWorkflow(idOrName, namespace_);
    }

    WorkflowExecution[] listExecutions() {
        return repository.listExecutions();
    }

    WorkflowExecution* getExecution(string id) {
        return repository.getExecution(id);
    }

    WorkflowExecution createExecution(ExecutionCommand command) {
        return repository.createExecution(
            command.workflowIdentifier,
            command.workflowNamespace,
            command.inputJson,
            command.description,
            command.tags,
            command.projectId
        );
    }

    bool deleteExecution(string id, bool force) {
        return repository.deleteExecution(id, force);
    }

    TaskExecution[] listTasks(string workflowExecutionId = "") {
        return repository.listTasks(workflowExecutionId);
    }

    TaskExecution* getTask(string id) {
        return repository.getTask(id);
    }

    ActionExecution[] listActionExecutions(string taskExecutionId = "") {
        return repository.listActionExecutions(taskExecutionId);
    }

    ActionExecution* getActionExecution(string id) {
        return repository.getActionExecution(id);
    }

    ActionExecution createActionExecution(ActionExecutionCommand command) {
        return repository.createActionExecution(
            command.name,
            command.description,
            command.inputJson,
            command.paramsJson,
            command.workflowName,
            command.taskName,
            command.taskExecutionId,
            command.projectId
        );
    }
}
