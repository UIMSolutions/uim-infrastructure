/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
