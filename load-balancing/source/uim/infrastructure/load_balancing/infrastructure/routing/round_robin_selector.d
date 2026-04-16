module lb_service.infrastructure.routing.round_robin_selector;

import core.atomic : atomicFetchAdd;
import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.selectors.backend : IBackendSelector;

class RoundRobinSelector : IBackendSelector {
    private shared uint counter = 0;

    override Backend* select(Backend[] backends) {
        Backend[] healthy;
        foreach (ref b; backends) {
            if (b.healthy) {
                healthy ~= b;
            }
        }

        if (healthy.length == 0) {
            return null;
        }

        auto index = atomicFetchAdd(counter, 1u) % cast(uint) healthy.length;
        // healthy is a GC-heap slice; returning a pointer into it is safe because
        // the GC tracks interior pointers and keeps the backing array alive.
        return &healthy[index];
    }
}

unittest {
    auto selector = new RoundRobinSelector();

    Backend[] pool = [
        Backend("b1", "10.0.0.1", 8080, 1, true),
        Backend("b2", "10.0.0.2", 8080, 1, true),
        Backend("b3", "10.0.0.3", 8080, 1, false)
    ];

    auto first  = selector.select(pool);
    auto second = selector.select(pool);
    auto third  = selector.select(pool);

    assert(first  !is null);
    assert(second !is null);
    assert(third  !is null);
    // Only two healthy backends; ids must cycle through b1 and b2
    assert(first.id  == "b1");
    assert(second.id == "b2");
    assert(third.id  == "b1");
}
