/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module lb_service.application.usecases.register_backend;

import lb_service.application.dto.backend_command : RegisterBackendCommand;
import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.repositories.backend : IBackendRepository;

class RegisterBackendUseCase {
    private IBackendRepository repository;

    this(IBackendRepository repository) {
        this.repository = repository;
    }

    Backend execute(in RegisterBackendCommand command) {
        enforceCommand(command);

        auto backend = Backend(
            command.id,
            command.host,
            command.port,
            command.weight == 0 ? 1 : command.weight,
            true
        );

        repository.save(backend);
        return backend;
    }

    private void enforceCommand(in RegisterBackendCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        if (command.host.length == 0) {
            throw new Exception("host must not be empty");
        }
        if (command.port == 0) {
            throw new Exception("port must be greater than zero");
        }
    }
}
