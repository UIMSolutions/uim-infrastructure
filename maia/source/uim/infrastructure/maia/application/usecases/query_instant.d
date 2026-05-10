module uim.infrastructure.maia.application.usecases.query_instant;

import uim.infrastructure.maia.application.dto.maia_commands : InstantQueryCommand;
import uim.infrastructure.maia.domain.entities.label_matcher : parseSelector;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;
import std.algorithm : map;
import std.array : array;
import std.datetime.systime : Clock;

struct InstantQueryResult {
    TimeSeries series;
    double     value;
    double     timestampSec;
}

class QueryInstantUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    InstantQueryResult[] execute(InstantQueryCommand command, Tenant tenant) {
        long atMs = command.atMs > 0
            ? command.atMs
            : Clock.currTime().toUnixTime() * 1000L;

        auto matchers  = parseSelector(command.selector);
        auto series    = repository.listSeries(matchers, tenant);
        auto seriesIds = series.map!(s => s.id).array;
        auto samples   = repository.getLatestSamples(seriesIds, atMs);

        InstantQueryResult[] results;
        foreach (sample; samples) {
            foreach (ts; series) {
                if (ts.id == sample.timeSeriesId) {
                    results ~= InstantQueryResult(ts, sample.value, sample.timestampSec());
                    break;
                }
            }
        }
        return results;
    }
}
