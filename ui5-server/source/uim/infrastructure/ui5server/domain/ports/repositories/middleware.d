module uim.infrastructure.ui5server.domain.ports.repositories.middleware;

import uim.infrastructure.ui5server.domain.entities.middleware : Middleware;

interface IMiddlewareRepository {
    bool save(Middleware mw);
    Middleware* findByName(string name);
    Middleware[] findAll();
    Middleware[] findAllOrdered();
    bool remove(string name);
    bool updateOrder(string name, uint newOrder);
    bool updateEnabled(string name, bool enabled);
}
