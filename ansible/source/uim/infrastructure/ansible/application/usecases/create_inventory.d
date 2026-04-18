module uim.infrastructure.ansible.application.usecases.create_inventory;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.ansible.application.dto.commands : CreateInventoryCommand;
import uim.infrastructure.ansible.domain.entities.inventory : Inventory, HostGroup;
import uim.infrastructure.ansible.domain.ports.repositories.inventory : IInventoryRepository;

class CreateInventoryUseCase {
    private IInventoryRepository repository;

    this(IInventoryRepository repository) {
        this.repository = repository;
    }

    Inventory execute(in CreateInventoryCommand command) {
        if (command.name.length == 0)
            throw new Exception("name must not be empty");

        auto id = generateId(command.name);

        HostGroup[] groups;
        foreach (g; command.groups) {
            string[string] gv;
            foreach (k, v; g.groupVars)
                gv[k] = v;
            groups ~= HostGroup(g.name, g.hostIds.dup, gv);
        }

        auto inventory = Inventory(id, command.name, command.description, groups);
        repository.save(inventory);
        return inventory;
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
