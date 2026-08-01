module app;

import std.conv : to;
import uim.infrastructure.openstack.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.openstack.application.usecases.list_servers : ListServersUseCase;
import uim.infrastructure.openstack.application.usecases.reboot_server : RebootServerUseCase;
import uim.infrastructure.openstack.infrastructure.config.settings : ServiceSettings;
import uim.infrastructure.openstack.infrastructure.http.clients.openstack_gateway : OpenStackGateway;
import uim.infrastructure.openstack.infrastructure.http.controllers.openstack_api_controller : OpenStackApiController;
import uim.infrastructure.openstack.infrastructure.http.controllers.web_controller : WebController;
import vibe.vibe;

void main() {
    auto serviceSettings = ServiceSettings.fromEnvironment();

    auto httpSettings = new HTTPServerSettings;
    httpSettings.port = serviceSettings.port;
    httpSettings.bindAddresses = [serviceSettings.bindAddress];

    auto gateway = new OpenStackGateway(serviceSettings);
    auto listProjectsUseCase = new ListProjectsUseCase(gateway);
    auto listServersUseCase = new ListServersUseCase(gateway);
    auto rebootServerUseCase = new RebootServerUseCase(gateway);

    auto apiController = new OpenStackApiController(
        listProjectsUseCase,
        listServersUseCase,
        rebootServerUseCase,
        serviceSettings.defaultRegion
    );
    auto webController = new WebController(serviceSettings);

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("OpenStack service starting on %s:%d", serviceSettings.bindAddress, serviceSettings.port.to!int);
    listenHTTP(httpSettings, router);
    runApplication();
}
