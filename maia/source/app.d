/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.infrastructure.maia.application.usecases.ingest_sample : IngestSampleUseCase;
import uim.infrastructure.maia.application.usecases.query_instant : QueryInstantUseCase;
import uim.infrastructure.maia.application.usecases.query_range : QueryRangeUseCase;
import uim.infrastructure.maia.application.usecases.list_series : ListSeriesUseCase;
import uim.infrastructure.maia.application.usecases.list_labels : ListLabelsUseCase;
import uim.infrastructure.maia.application.usecases.list_label_values : ListLabelValuesUseCase;
import uim.infrastructure.maia.application.usecases.authenticate : AuthenticateUseCase;
import uim.infrastructure.maia.infrastructure.http.controllers.maia : MaiaController;
import uim.infrastructure.maia.infrastructure.auth.static_token_repository : StaticTokenRepository;
import uim.infrastructure.maia.infrastructure.persistence.memory.time_series_repository : InMemoryTimeSeriesRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto tsRepo    = new InMemoryTimeSeriesRepository();
    auto tokenRepo = new StaticTokenRepository(readDebugToken());

    auto controller = new MaiaController(
        new AuthenticateUseCase(tokenRepo),
        new IngestSampleUseCase(tsRepo),
        new QueryInstantUseCase(tsRepo),
        new QueryRangeUseCase(tsRepo),
        new ListSeriesUseCase(tsRepo),
        new ListLabelsUseCase(tsRepo),
        new ListLabelValuesUseCase(tsRepo)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Maia service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) return 8080;
    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readDebugToken() {
    auto raw = getenv("MAIA_DEBUG_TOKEN");
    return raw is null ? "debug-token" : fromStringz(raw).idup;
}
