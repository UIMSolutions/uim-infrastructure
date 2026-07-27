/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.application.usecases.query_range;

import uim.infrastructure.maia.application.dto.maia_commands : RangeQueryCommand;
import uim.infrastructure.maia.domain.entities.label_matcher : parseSelector;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;
import std.algorithm : map, sort;
import std.array : array;

struct RangeSeries {
    TimeSeries series;
    Sample[]   samples; // ordered by timestamp ascending
}

class QueryRangeUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    RangeSeries[] execute(RangeQueryCommand command, Tenant tenant) {
        if (command.startMs >= command.endMs) {
            throw new Exception("start must be before end");
        }

        auto matchers  = parseSelector(command.selector);
        auto series    = repository.listSeries(matchers, tenant);
        auto seriesIds = series.map!(s => s.id).array;
        auto allSamples = repository.getRangeSamples(seriesIds, command.startMs, command.endMs);

        // Group samples by time series
        RangeSeries[] results;
        foreach (ts; series) {
            Sample[] tsSamples;
            foreach (s; allSamples) {
                if (s.timeSeriesId == ts.id) tsSamples ~= s;
            }
            if (tsSamples.length > 0) {
                tsSamples.sort!((a, b) => a.timestampMs < b.timestampMs);
                results ~= RangeSeries(ts, tsSamples);
            }
        }
        return results;
    }
}
