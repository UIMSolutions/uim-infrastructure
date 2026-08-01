module uim.infrastructure.sdk_ai.application.usecases.generate_chat_completion;

import std.datetime : Clock;
import uim.infrastructure.sdk_ai.application.dto.chat_completion_command : ChatCompletionCommand;
import uim.infrastructure.sdk_ai.domain.entities.chat :
    ChatCompletionRequest,
    ChatCompletionResponse,
    ChatMessage,
    TokenUsage;
import uim.infrastructure.sdk_ai.domain.ports.ai_model_gateway : IAiModelGateway;

class GenerateChatCompletionUseCase {
    private IAiModelGateway gateway;

    this(IAiModelGateway gateway) {
        this.gateway = gateway;
    }

    ChatCompletionResponse execute(ChatCompletionCommand command) {
        auto sanitized = sanitize(command);
        auto request = ChatCompletionRequest(
            sanitized.tenantId,
            sanitized.model,
            sanitized.messages,
            sanitized.temperature,
            sanitized.maxTokens
        );

        return gateway.generateChatCompletion(request);
    }

    private ChatCompletionCommand sanitize(ChatCompletionCommand command) {
        if (command.model.length == 0) {
            command.model = "gpt-4o-mini";
        }

        if (command.maxTokens <= 0) {
            command.maxTokens = 1024;
        }

        if (command.temperature < 0.0 || command.temperature > 2.0) {
            command.temperature = 0.2;
        }

        if (command.messages.length == 0) {
            command.messages = [ChatMessage("user", "Hello")];
        }

        return command;
    }
}
