module app;

import vpc_service.application.usecases.create_vpc    : CreateVpcUseCase;
import vpc_service.application.usecases.delete_vpc    : DeleteVpcUseCase;
import vpc_service.application.usecases.list_vpcs     : ListVpcsUseCase;
import vpc_service.application.usecases.get_vpc       : GetVpcUseCase;
import vpc_service.application.usecases.create_subnet : CreateSubnetUseCase;
import vpc_service.application.usecases.delete_subnet : DeleteSubnetUseCase;
import vpc_service.application.usecases.list_subnets  : ListSubnetsUseCase;
import vpc_service.infrastructure.http.controllers.vpc : VpcController;
import vpc_service.infrastructure.persistence.memory.vpc_repository    : InMemoryVpcRepository;
import vpc_service.infrastructure.persistence.memory.subnet_repository : InMemorySubnetRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto vpcRepository    = new InMemoryVpcRepository();
    auto subnetRepository = new InMemorySubnetRepository();

    auto controller = new VpcController(
        new CreateVpcUseCase(vpcRepository),
        new DeleteVpcUseCase(vpcRepository),
        new ListVpcsUseCase(vpcRepository),
        new GetVpcUseCase(vpcRepository),
        new CreateSubnetUseCase(vpcRepository, subnetRepository),
        new DeleteSubnetUseCase(subnetRepository),
        new ListSubnetsUseCase(subnetRepository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("VPC service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
