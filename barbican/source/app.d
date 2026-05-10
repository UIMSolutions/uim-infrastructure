module app;

import uim.infrastructure.barbican.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.barbican.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.barbican.application.usecases.get_secret : GetSecretUseCase;
import uim.infrastructure.barbican.application.usecases.delete_secret : DeleteSecretUseCase;
import uim.infrastructure.barbican.application.usecases.set_secret_payload : SetSecretPayloadUseCase;
import uim.infrastructure.barbican.application.usecases.get_secret_payload : GetSecretPayloadUseCase;
import uim.infrastructure.barbican.application.usecases.create_container : CreateContainerUseCase;
import uim.infrastructure.barbican.application.usecases.list_containers : ListContainersUseCase;
import uim.infrastructure.barbican.application.usecases.get_container : GetContainerUseCase;
import uim.infrastructure.barbican.application.usecases.delete_container : DeleteContainerUseCase;
import uim.infrastructure.barbican.application.usecases.create_order : CreateOrderUseCase;
import uim.infrastructure.barbican.application.usecases.list_orders : ListOrdersUseCase;
import uim.infrastructure.barbican.application.usecases.get_order : GetOrderUseCase;
import uim.infrastructure.barbican.application.usecases.delete_order : DeleteOrderUseCase;
import uim.infrastructure.barbican.infrastructure.http.controllers.barbican : BarbicanController;
import uim.infrastructure.barbican.infrastructure.persistence.memory.secret_repository : InMemorySecretRepository;
import uim.infrastructure.barbican.infrastructure.persistence.memory.secret_container_repository : InMemorySecretContainerRepository;
import uim.infrastructure.barbican.infrastructure.persistence.memory.order_repository : InMemoryOrderRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    // --- Outbound adapters (repositories) ---
    auto secretRepo    = new InMemorySecretRepository();
    auto containerRepo = new InMemorySecretContainerRepository();
    auto orderRepo     = new InMemoryOrderRepository();

    // --- Use cases ---
    auto createSecretUC    = new CreateSecretUseCase(secretRepo);
    auto listSecretsUC     = new ListSecretsUseCase(secretRepo);
    auto getSecretUC       = new GetSecretUseCase(secretRepo);
    auto deleteSecretUC    = new DeleteSecretUseCase(secretRepo);
    auto setPayloadUC      = new SetSecretPayloadUseCase(secretRepo);
    auto getPayloadUC      = new GetSecretPayloadUseCase(secretRepo);
    auto createContainerUC = new CreateContainerUseCase(containerRepo);
    auto listContainersUC  = new ListContainersUseCase(containerRepo);
    auto getContainerUC    = new GetContainerUseCase(containerRepo);
    auto deleteContainerUC = new DeleteContainerUseCase(containerRepo);
    auto createOrderUC     = new CreateOrderUseCase(orderRepo, secretRepo);
    auto listOrdersUC      = new ListOrdersUseCase(orderRepo);
    auto getOrderUC        = new GetOrderUseCase(orderRepo);
    auto deleteOrderUC     = new DeleteOrderUseCase(orderRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new BarbicanController(
        createSecretUC, listSecretsUC, getSecretUC, deleteSecretUC,
        setPayloadUC, getPayloadUC,
        createContainerUC, listContainersUC, getContainerUC, deleteContainerUC,
        createOrderUC, listOrdersUC, getOrderUC, deleteOrderUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Barbican key-manager service starting on %s:%d",
            settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) return cast(ushort) 9311;
    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 9311;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
