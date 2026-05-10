module uim.infrastructure.barbican.domain.ports.repositories.order;

import uim.infrastructure.barbican.domain.entities.order : Order, OrderStatus;

interface IOrderRepository {
    void save(in Order order);
    void remove(string id);
    Order[] list(string projectId = "");
    Order* findById(string id);
    bool updateStatus(string id, OrderStatus status, string secretRef, string errorCode, string errorReason);
}
