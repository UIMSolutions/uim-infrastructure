module app;

import std.conv : to;
import uim.infrastructure.sdk_ai.application.usecases.generate_chat_completion : GenerateChatCompletionUseCase;
import uim.infrastructure.sdk_ai.application.usecases.list_models : ListModelsUseCase;
import uim.infrastructure.sdk_ai.infrastructure.config.settings : ServiceSettings;
import uim.infrastructure.sdk_ai.infrastructure.http.clients.sap_ai_gateway : SapAiGateway;
import uim.infrastructure.sdk_ai.infrastructure.http.controllers.ai_api_controller : AiApiController;
import uim.infrastructure.sdk_ai.infrastructure.http.controllers.web_controller : WebController;
import vibe.vibe;

void main() {
    auto serviceSettings = ServiceSettings.fromEnvironment();

    auto httpSettings = new HTTPServerSettings;
    httpSettings.port = serviceSettings.port;
    httpSettings.bindAddresses = [serviceSettings.bindAddress];

    auto gateway = new SapAiGateway(serviceSettings);
    auto listModelsUseCase = new ListModelsUseCase(gateway);
    auto generateUseCase = new GenerateChatCompletionUseCase(gateway);

    auto apiController = new AiApiController(listModelsUseCase, generateUseCase);
    auto webController = new WebController(serviceSettings);

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("SDK-AI service starting on %s:%d", serviceSettings.bindAddress, serviceSettings.port.to!int);
    listenHTTP(httpSettings, router);
    runApplication();
}
