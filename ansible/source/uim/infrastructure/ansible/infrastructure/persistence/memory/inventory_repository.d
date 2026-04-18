module uim.infrastructure.ansible.infrastructure.persistence.memory.inventory_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ansible.domain.entities.inventory : Inventory, HostGroup;
import uim.infrastructure.ansible.domain.ports.repositories.inventory : IInventoryRepository;

class InMemoryInventoryRepository : IInventoryRepository {
    private Inventory[] inventories;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    private Inventory copyInventory(in Inventory inv) {
        HostGroup[] groups;
        foreach (g; inv.groups) {
            string[string] gv;
            foreach (k, v; g.groupVars)
                gv[k] = v;
            groups ~= HostGroup(g.name, g.hostIds.dup, gv);
        }
        return Inventory(inv.id, inv.name, inv.description, groups);
    }

    override void save(in Inventory inventory) {
        synchronized (mutex) {
            auto copy = copyInventory(inventory);
            foreach (i, ref existing; inventories) {
                if (existing.id == inventory.id) {
                    inventories[i] = copy;
                    return;
                }
            }
            inventories ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Inventory[] filtered;
            foreach (inv; inventories) {
                if (inv.id != id)
                    filtered ~= inv;
            }
            inventories = filtered;
        }
    }

    override Inventory[] list() {
        synchronized (mutex) {
            return inventories.dup;
        }
    }

    override Inventory* findById(string id) {
        synchronized (mutex) {
            foreach (ref inv; inventories) {
                if (inv.id == id)
                    return &inv;
            }
            return null;
        }
    }
}

unittest {
    auto repo = new InMemoryInventoryRepository();
    auto inv = Inventory("i1", "prod", "Production", [
        HostGroup("web", ["h1", "h2"], null)
    ]);
    repo.save(inv);

    assert(repo.list().length == 1);
    assert(repo.findById("i1") !is null);
    assert(repo.findById("i1").name == "prod");

    repo.remove("i1");
    assert(repo.list().length == 0);
}
