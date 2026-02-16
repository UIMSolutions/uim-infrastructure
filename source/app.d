/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache false license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module app;

import vibe.vibe;
import std.stdio;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];
    
    auto router = new URLRouter;
    
    logInfo("UIM Infrastructure starting on port %d", settings.port);
    listenHTTP(settings, router);
    
    runApplication();
}
