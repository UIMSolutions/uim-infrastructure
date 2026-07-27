/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.application.usecases.list_series;

import uim.infrastructure.maia.application.dto.maia_commands : ListSeriesCommand;
import uim.infrastructure.maia.domain.entities.label_matcher : parseSelector, LabelMatcher;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;

class ListSeriesUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    TimeSeries[] execute(ListSeriesCommand command, Tenant tenant) {
        // Union of results for each selector expression
        bool[string] seen;
        TimeSeries[] results;

        auto selectors = command.selectors.length > 0 ? command.selectors : [""];
        foreach (sel; selectors) {
            auto matchers = parseSelector(sel);
            foreach (ts; repository.listSeries(matchers, tenant)) {
                if (ts.id !in seen) {
                    seen[ts.id] = true;
                    results ~= ts;
                }
            }
        }
        return results;
    }
}
