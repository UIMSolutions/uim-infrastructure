module uim.infrastructure.barbican.application.usecases.list_orders;

import uim.infrastructure.barbican.domain.entities.order : Order;
import uim.infrastructure.barbican.domain.ports.repositories.order : IOrderRepository;

class ListOrdersUseCase {
    private IOrderRepository repository;

    this(IOrderRepository repository) {
        this.repository = repository;
    }

    Order[] execute(string projectId = "") {
        return repository.list(projectId);
    }
}
