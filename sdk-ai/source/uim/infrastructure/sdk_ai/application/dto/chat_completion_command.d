module uim.infrastructure.sdk_ai.application.dto.chat_completion_command;

import uim.infrastructure.sdk_ai.domain.entities.chat : ChatMessage;

struct ChatCompletionCommand {
    string tenantId;
    string model;
    ChatMessage[] messages;
    double temperature;
    int maxTokens;
}
