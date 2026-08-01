module uim.infrastructure.sdk_ai.domain.entities.chat;

struct ChatMessage {
    string role;
    string content;
}

struct TokenUsage {
    int promptTokens;
    int completionTokens;
    int totalTokens;
}

struct ChatCompletionRequest {
    string tenantId;
    string model;
    ChatMessage[] messages;
    double temperature;
    int maxTokens;
}

struct ChatCompletionResponse {
    string id;
    string provider;
    string model;
    string content;
    long createdAtUnix;
    TokenUsage usage;
}
