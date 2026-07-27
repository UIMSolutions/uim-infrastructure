/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module log_service.domain.ports.repositories.logs;

import log_service.domain.entities.log_entry : LogEntry, LogLevel;

interface ILogsRepository {
    void save(in LogEntry entry);
    LogEntry[] list();
    LogEntry[] findByService(string service);
    LogEntry[] findByServiceAndLevel(string service, LogLevel level);
}
