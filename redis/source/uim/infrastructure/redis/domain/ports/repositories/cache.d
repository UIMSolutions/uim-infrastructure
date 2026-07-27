/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module redis_service.domain.ports.repositories.cache;

import redis_service.domain.entities.cache_entry : CacheEntry;
import std.typecons : Nullable;

interface ICacheRepository {
    void set(in CacheEntry entry);
    Nullable!CacheEntry get(string key);
    void remove(string key);
    string[] listKeys();
}
