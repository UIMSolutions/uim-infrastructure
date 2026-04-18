module uim.infrastructure.crossplane.infrastructure.persistence.memory.claim_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.crossplane.domain.entities.claim : Claim;
import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;

class InMemoryClaimRepository : IClaimRepository {
    private Claim[] claims;
    private Mutex mutex;

    this() { mutex = new Mutex; }

    private Claim copyClaim(in Claim c) {
        string[string] params;
        foreach (k, v; c.parameters) params[k] = v;
        return Claim(c.id, c.name, c.namespace, c.compositeRef, c.compositionRef,
            params, c.status, c.boundResourceId, c.createdAt, c.updatedAt);
    }

    override void save(in Claim claim) {
        synchronized (mutex) {
            auto copy = copyClaim(claim);
            foreach (i, ref existing; claims) {
                if (existing.id == claim.id) { claims[i] = copy; return; }
            }
            claims ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Claim[] filtered;
            foreach (c; claims) if (c.id != id) filtered ~= c;
            claims = filtered;
        }
    }

    override Claim[] list() {
        synchronized (mutex) { return claims.dup; }
    }

    override Claim* findById(string id) {
        synchronized (mutex) {
            foreach (ref c; claims) if (c.id == id) return &c;
            return null;
        }
    }

    override Claim[] findByNamespace(string namespace) {
        synchronized (mutex) {
            Claim[] result;
            foreach (c; claims) if (c.namespace == namespace) result ~= c;
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.crossplane.domain.entities.claim : ClaimStatus;

    auto repo = new InMemoryClaimRepository();
    string[string] params;
    params["region"] = "us-east-1";
    auto claim = Claim("cl1", "my-db", "team-a", "", "rds-comp",
        params, ClaimStatus.PENDING, "", "2026-04-19", "2026-04-19");
    repo.save(claim);
    assert(repo.list().length == 1);
    assert(repo.findByNamespace("team-a").length == 1);
    repo.remove("cl1");
    assert(repo.list().length == 0);
}
