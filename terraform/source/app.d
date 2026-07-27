/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;


import uim.infrastructure.terraform.application.usecases.get_terraform_version : GetTerraformVersionUseCase;
import uim.infrastructure.terraform.application.usecases.run_terraform_action : RunTerraformActionUseCase;
import uim.infrastructure.terraform.infrastructure.cli.terraform_cli_runner : TerraformCliRunner;
import uim.infrastructure.terraform.infrastructure.http.controllers.terraform : TerraformController;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toLower, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto runner = new TerraformCliRunner(readEnv("TERRAFORM_BINARY", "terraform"));
    auto defaultModulePath = readEnv("TERRAFORM_DEFAULT_MODULE_PATH", "/app/modules/example");
    auto defaultAutoApprove = readBoolEnv("TERRAFORM_AUTO_APPROVE", true);

    auto controller = new TerraformController(
        new GetTerraformVersionUseCase(runner),
        new RunTerraformActionUseCase(runner, defaultModulePath, defaultAutoApprove)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo(
        "Terraform service starting on %s:%d (binary=%s)",
        settings.bindAddresses[0],
        settings.port,
        readEnv("TERRAFORM_BINARY", "terraform")
    );

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

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}

private bool readBoolEnv(string key, bool fallback) {
    auto value = readEnv(key, fallback ? "true" : "false").toLower();
    return value == "1" || value == "true" || value == "yes" || value == "on";
}
