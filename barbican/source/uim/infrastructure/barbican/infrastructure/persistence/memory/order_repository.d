/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.infrastructure.persistence.memory.order_repository;

import core.sync.mutex : Mutex;
import std.datetime : Clock;
import uim.infrastructure.barbican.domain.entities.order : Order, OrderMeta, OrderStatus, OrderType;
import uim.infrastructure.barbican.domain.ports.repositories.order : IOrderRepository;

class InMemoryOrderRepository : IOrderRepository {
    private Order[] orders;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Order order) {
        synchronized (mutex) {
            foreach (i, ref existing; orders) {
                if (existing.id == order.id) {
                    orders[i] = copyOrder(order);
                    return;
                }
            }
            orders ~= copyOrder(order);
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Order[] filtered;
            foreach (o; orders) {
                if (o.id != id)
                    filtered ~= o;
            }
            orders = filtered;
        }
    }

    override Order[] list(string projectId = "") {
        synchronized (mutex) {
            if (projectId.length == 0)
                return orders.dup;
            Order[] result;
            foreach (o; orders) {
                if (o.projectId == projectId)
                    result ~= o;
            }
            return result;
        }
    }

    override Order* findById(string id) {
        synchronized (mutex) {
            foreach (ref o; orders) {
                if (o.id == id)
                    return &o;
            }
            return null;
        }
    }

    override bool updateStatus(string id, OrderStatus status, string secretRef,
                               string errorCode, string errorReason) {
        synchronized (mutex) {
            foreach (ref o; orders) {
                if (o.id == id) {
                    o.status = status;
                    o.secretRef = secretRef;
                    o.errorStatusCode = errorCode;
                    o.errorReason = errorReason;
                    o.updatedAt = Clock.currTime.toISOExtString();
                    return true;
                }
            }
            return false;
        }
    }

    private Order copyOrder(in Order src) {
        Order dst;
        dst.id = src.id;
        dst.orderType = src.orderType;
        dst.status = src.status;
        dst.meta = OrderMeta(
            src.meta.algorithm,
            src.meta.bitLength,
            src.meta.mode,
            src.meta.payloadContentType,
            src.meta.expiration,
            src.meta.name
        );
        dst.secretRef = src.secretRef;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        dst.errorStatusCode = src.errorStatusCode;
        dst.errorReason = src.errorReason;
        return dst;
    }
}
