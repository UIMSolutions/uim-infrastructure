module lb_service.domain.ports.selectors.backend;

import lb_service.domain.entities.backend : Backend;

interface IBackendSelector {
    /// Select the next healthy backend from the given pool.
    /// Returns null when no healthy backend is available.
    Backend* select(Backend[] backends);
}
