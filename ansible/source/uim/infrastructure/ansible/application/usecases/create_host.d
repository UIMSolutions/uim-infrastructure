module uim.infrastructure.ansible.application.usecases.create_host;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.ansible.application.dto.commands : CreateHostCommand;
import uim.infrastructure.ansible.domain.entities.host : Host, HostStatus;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class CreateHostUseCase {
    private IHostRepository repository;

    this(IHostRepository repository) {
        this.repository = repository;
    }

    Host execute(in CreateHostCommand command) {
        enforceCommand(command);

        auto id = generateId(command.hostname);
        string[string] vars;
        foreach (k, v; command.variables)
            vars[k] = v;

        auto host = Host(
            id,
            command.hostname,
            command.ipAddress,
            command.port == 0 ? cast(ushort) 22 : command.port,
            command.user.length == 0 ? "root" : command.user,
            HostStatus.UNKNOWN,
            vars
        );

        repository.save(host);
        return host;
    }

    private void enforceCommand(in CreateHostCommand command) {
        if (command.hostname.length == 0)
            throw new Exception("hostname must not be empty");
        if (command.ipAddress.length == 0)
            throw new Exception("ipAddress must not be empty");
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
