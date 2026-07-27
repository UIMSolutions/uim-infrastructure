/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.application.usecases.ingest_sample;

import uim.infrastructure.maia.application.dto.maia_commands : IngestSampleCommand;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;
import std.datetime.systime : Clock;

class IngestSampleUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    void execute(IngestSampleCommand command) {
        if (command.labels.get("__name__", "").length == 0) {
            throw new Exception("label __name__ must not be empty");
        }

        long ts = command.timestampMs > 0
            ? command.timestampMs
            : Clock.currTime().toUnixTime() * 1000L;

        string tsId = repository.ensureTimeSeries(command.labels);
        repository.saveSample(Sample(tsId, command.value, ts));
    }
}

unittest {
    import uim.infrastructure.maia.infrastructure.persistence.memory.time_series_repository : InMemoryTimeSeriesRepository;

    auto repo    = new InMemoryTimeSeriesRepository();
    auto useCase = new IngestSampleUseCase(repo);

    IngestSampleCommand cmd;
    cmd.labels      = ["__name__": "up", "project_id": "p1", "job": "os"];
    cmd.value       = 1.0;
    cmd.timestampMs = 1_620_000_000_000L;

    useCase.execute(cmd);

    import uim.infrastructure.maia.domain.entities.tenant : Tenant;
    auto series = repo.listSeries([], Tenant("p1", ""));
    assert(series.length == 1);
    assert(series[0].name() == "up");
}
