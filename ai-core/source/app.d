/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.ai_core.infrastructure.config;
import uim.platform.ai_core.infrastructure.container;

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.scenarioController.registerRoutes(router);
        container.executableController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.executionController.registerRoutes(router);
        container.deploymentController.registerRoutes(router);
        container.artifactController.registerRoutes(router);
        container.resourceGroupController.registerRoutes(router);
        container.metricController.registerRoutes(router);
        container.metaController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  AI Core Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  AI API v2 Endpoints:                                    ");
        writefln("    GET       /api/v2/lm/meta              (Capabilities) ");
        writefln("    CRUD      /api/v2/lm/scenarios                        ");
        writefln("    CRUD      /api/v2/lm/executables                      ");
        writefln("    CRUD      /api/v2/lm/configurations                   ");
        writefln("    CRUD+PATCH /api/v2/lm/executions                      ");
        writefln("    CRUD+PATCH /api/v2/lm/deployments                     ");
        writefln("    CRUD      /api/v2/lm/artifacts                        ");
        writefln("    GET+PATCH /api/v2/lm/metrics                          ");
        writefln("                                                          ");
        writefln("  Admin Endpoints:                                        ");
        writefln("    CRUD+PATCH /api/v2/admin/resourceGroups               ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET       /api/v1/health                              ");
        writefln("==========================================================");

        runApplication();
    }
}
