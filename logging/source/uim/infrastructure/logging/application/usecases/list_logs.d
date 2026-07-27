/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module log_service.application.usecases.list_logs;

import log_service.domain.entities.log_entry : LogEntry;
import log_service.domain.ports.repositories.logs : ILogsRepository;

class ListLogsUseCase {
    private ILogsRepository repository;

    this(ILogsRepository repository) {
        this.repository = repository;
    }

    LogEntry[] execute() {
        return repository.list();
    }
}
