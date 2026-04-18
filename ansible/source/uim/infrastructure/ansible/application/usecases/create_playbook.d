module uim.infrastructure.ansible.application.usecases.create_playbook;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.ansible.application.dto.commands : CreatePlaybookCommand;
import uim.infrastructure.ansible.domain.entities.playbook : Playbook, Play;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class CreatePlaybookUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    Playbook execute(in CreatePlaybookCommand command) {
        if (command.name.length == 0)
            throw new Exception("name must not be empty");

        auto id = generateId(command.name);

        Play[] plays;
        foreach (p; command.plays) {
            string[string] pv;
            foreach (k, v; p.vars)
                pv[k] = v;
            plays ~= Play(p.name, p.targetGroup, p.taskIds.dup, pv, p.become);
        }

        auto playbook = Playbook(id, command.name, command.description, plays);
        repository.save(playbook);
        return playbook;
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
