module uim.infrastructure.crossplane.infrastructure.persistence.memory.composition_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.crossplane.domain.entities.composition : Composition, ComposedTemplate;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class InMemoryCompositionRepository : ICompositionRepository {
    private Composition[] compositions;
    private Mutex mutex;

    this() { mutex = new Mutex; }

    private Composition copyComposition(in Composition c) {
        ComposedTemplate[] resources;
        foreach (r; c.resources) {
            string[string] patches;
            foreach (k, v; r.patches) patches[k] = v;
            string[string] base;
            foreach (k, v; r.base) base[k] = v;
            resources ~= ComposedTemplate(r.name, r.kind, r.apiGroup, patches, base);
        }
        string[string] secrets;
        foreach (k, v; c.writeConnectionSecretsToRef) secrets[k] = v;
        return Composition(c.id, c.name, c.compositeTypeRef, resources,
            secrets, c.createdAt, c.updatedAt);
    }

    override void save(in Composition composition) {
        synchronized (mutex) {
            auto copy = copyComposition(composition);
            foreach (i, ref existing; compositions) {
                if (existing.id == composition.id) { compositions[i] = copy; return; }
            }
            compositions ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Composition[] filtered;
            foreach (c; compositions) if (c.id != id) filtered ~= c;
            compositions = filtered;
        }
    }

    override Composition[] list() {
        synchronized (mutex) { return compositions.dup; }
    }

    override Composition* findById(string id) {
        synchronized (mutex) {
            foreach (ref c; compositions) if (c.id == id) return &c;
            return null;
        }
    }
}

unittest {
    auto repo = new InMemoryCompositionRepository();
    auto tpl = ComposedTemplate("bucket", "Bucket", "s3.aws", null, null);
    auto comp = Composition("c1", "s3-comp", "XObjectStorage", [tpl], null, "2026-04-19", "");
    repo.save(comp);
    assert(repo.list().length == 1);
    assert(repo.findById("c1") !is null);
    repo.remove("c1");
    assert(repo.list().length == 0);
}
