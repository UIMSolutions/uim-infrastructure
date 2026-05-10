module uim.infrastructure.barbican.application.usecases.delete_order;

import uim.infrastructure.barbican.domain.ports.repositories.order : IOrderRepository;

class DeleteOrderUseCase {
    private IOrderRepository repository;

    this(IOrderRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto ptr = repository.findById(id);
        if (ptr is null)
            throw new Exception("Order not found: " ~ id);
        repository.remove(id);
    }
}
