module uim.infrastructure.crossplane.infrastructure.persistence.memory.provider_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.crossplane.domain.entities.provider : Provider, ProviderCredential;
import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;

class InMemoryProviderRepository : IProviderRepository {
    private Provider[] providers;
    private Mutex mutex;

    this() { mutex = new Mutex; }

    private Provider copyProvider(in Provider p) {
        ProviderCredential[] creds;
        foreach (c; p.credentials)
            creds ~= ProviderCredential(c.key, c.secretRef);
        string[string] cfg;
        foreach (k, v; p.config) cfg[k] = v;
        return Provider(p.id, p.name, p.providerType, p.packageRef,
            p.status, p.region, creds, cfg, p.createdAt);
    }

    override void save(in Provider provider) {
        synchronized (mutex) {
            auto copy = copyProvider(provider);
            foreach (i, ref existing; providers) {
                if (existing.id == provider.id) { providers[i] = copy; return; }
            }
            providers ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Provider[] filtered;
            foreach (p; providers) if (p.id != id) filtered ~= p;
            providers = filtered;
        }
    }

    override Provider[] list() {
        synchronized (mutex) { return providers.dup; }
    }

    override Provider* findById(string id) {
        synchronized (mutex) {
            foreach (ref p; providers) if (p.id == id) return &p;
            return null;
        }
    }
}

unittest {
    import uim.infrastructure.crossplane.domain.entities.provider : ProviderType, ProviderStatus;

    auto repo = new InMemoryProviderRepository();
    auto p = Provider("p1", "aws", ProviderType.AWS, "provider-aws:v0.30",
        ProviderStatus.HEALTHY, "us-east-1", [], null, "2026-04-19");
    repo.save(p);
    assert(repo.list().length == 1);
    assert(repo.findById("p1") !is null);
    repo.remove("p1");
    assert(repo.list().length == 0);
}
