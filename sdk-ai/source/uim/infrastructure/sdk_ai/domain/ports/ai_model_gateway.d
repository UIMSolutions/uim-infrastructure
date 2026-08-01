module uim.infrastructure.sdk_ai.domain.ports.ai_model_gateway;

import uim.infrastructure.sdk_ai.domain.entities.chat : ChatCompletionRequest, ChatCompletionResponse;
import uim.infrastructure.sdk_ai.domain.entities.model_info : ModelInfo;

interface IAiModelGateway {
    ModelInfo[] listModels(string tenantId);
    ChatCompletionResponse generateChatCompletion(ChatCompletionRequest request);
}
