/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.domain.ports.repositories.order;

import uim.infrastructure.barbican.domain.entities.order : Order, OrderStatus;

interface IOrderRepository {
    void save(in Order order);
    void remove(string id);
    Order[] list(string projectId = "");
    Order* findById(string id);
    bool updateStatus(string id, OrderStatus status, string secretRef, string errorCode, string errorReason);
}
