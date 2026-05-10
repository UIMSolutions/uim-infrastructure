module uim.infrastructure.barbican.application.usecases.get_order;

import uim.infrastructure.barbican.domain.entities.order : Order;
import uim.infrastructure.barbican.domain.ports.repositories.order : IOrderRepository;

class GetOrderUseCase {
    private IOrderRepository repository;

    this(IOrderRepository repository) {
        this.repository = repository;
    }

    Order* execute(string id) {
        return repository.findById(id);
    }
}
