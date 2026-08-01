module uim.infrastructure.sdk_ai.application.usecases.list_models;

import uim.infrastructure.sdk_ai.domain.entities.model_info : ModelInfo;
import uim.infrastructure.sdk_ai.domain.ports.ai_model_gateway : IAiModelGateway;

class ListModelsUseCase {
    private IAiModelGateway gateway;

    this(IAiModelGateway gateway) {
        this.gateway = gateway;
    }

    ModelInfo[] execute(string tenantId) {
        return gateway.listModels(tenantId);
    }
}
