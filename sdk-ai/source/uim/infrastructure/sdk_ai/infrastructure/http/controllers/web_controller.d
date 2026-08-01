module uim.infrastructure.sdk_ai.infrastructure.http.controllers.web_controller;

import uim.infrastructure.sdk_ai.infrastructure.config.settings : ServiceSettings;
import uim.infrastructure.sdk_ai.infrastructure.http.views.dashboard_view : renderDashboardPage;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class WebController {
    private ServiceSettings settings;

    this(ServiceSettings settings) {
        this.settings = settings;
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/web", &home);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        auto html = renderDashboardPage(settings.sdkProvider, settings.defaultTenantId);
        res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
}
