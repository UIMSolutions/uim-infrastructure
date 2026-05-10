module uim.infrastructure.barbican.application.usecases.create_order;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.barbican.application.dto.commands : CreateOrderCommand;
import uim.infrastructure.barbican.domain.entities.order : Order, OrderMeta, OrderStatus, parseOrderType;
import uim.infrastructure.barbican.domain.entities.secret : Secret, SecretType, SecretStatus,
    SecretAlgorithm, parseSecretAlgorithm;
import uim.infrastructure.barbican.domain.ports.repositories.order : IOrderRepository;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class CreateOrderUseCase {
    private IOrderRepository orderRepo;
    private ISecretRepository secretRepo;

    this(IOrderRepository orderRepo, ISecretRepository secretRepo) {
        this.orderRepo = orderRepo;
        this.secretRepo = secretRepo;
    }

    Order execute(in CreateOrderCommand cmd) {
        if (cmd.orderType.length == 0)
            throw new Exception("orderType must not be empty");
        if (cmd.algorithm.length == 0)
            throw new Exception("algorithm must not be empty");

        auto id = generateId(cmd.orderType ~ cmd.algorithm);
        auto now = Clock.currTime.toISOExtString();

        auto meta = OrderMeta(
            cmd.algorithm,
            cmd.bitLength,
            cmd.mode,
            cmd.payloadContentType,
            cmd.expiration,
            cmd.name
        );

        auto order = Order(
            id,
            parseOrderType(cmd.orderType),
            OrderStatus.pending,
            meta,
            "",
            now,
            now,
            cmd.projectId,
            "",
            ""
        );

        orderRepo.save(order);

        // Synchronously fulfill the order by generating a stub secret payload
        auto secret = fulfillOrder(order);
        secretRepo.save(secret);

        auto secretRef = "/v1/secrets/" ~ secret.id;
        orderRepo.updateStatus(id, OrderStatus.active, secretRef, "", "");

        order.status = OrderStatus.active;
        order.secretRef = secretRef;
        return order;
    }

    private Secret fulfillOrder(in Order order) {
        import std.base64 : Base64;
        auto id = generateId(order.id ~ "secret");
        auto now = Clock.currTime.toISOExtString();

        // Generate a placeholder payload (in production, use a real key-gen library)
        auto rawPayload = "generated-key-for-" ~ order.id;
        auto payload = Base64.encode(cast(ubyte[]) rawPayload).idup;

        SecretType stype;
        final switch (order.orderType) {
            case OrderType.key:         stype = SecretType.symmetric; break;
            case OrderType.asymmetric:  stype = SecretType.asymmetric; break;
            case OrderType.certificate: stype = SecretType.certificate; break;
        }

        return Secret(
            id,
            order.meta.name.length > 0 ? order.meta.name : ("order-secret-" ~ order.id),
            stype,
            parseSecretAlgorithm(order.meta.algorithm),
            order.meta.bitLength,
            order.meta.mode,
            payload,
            order.meta.payloadContentType.length > 0 ? order.meta.payloadContentType : "application/octet-stream",
            order.meta.expiration,
            SecretStatus.active,
            now,
            now,
            order.projectId
        );
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}

private alias OrderType = uim.infrastructure.barbican.domain.entities.order.OrderType;
