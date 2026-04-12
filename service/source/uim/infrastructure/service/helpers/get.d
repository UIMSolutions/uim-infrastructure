/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.service.helpers.get;

import uim.infrastructure.service;

mixin(ShowModule!());

@safe:

// #region getLong
long getLong(Json json, string key, long defaultValue = 0) {
  return key in json && json[key].isInteger ? json[key].get!long : defaultValue;
}

long getLong(Json[string] json, string key, long defaultValue = 0) {
  Json value = json.get(key, Json(defaultValue));
  return value.isInteger ? value.get!long : defaultValue;
}

long getLong(Json json, long defaultValue = 0) {
  return json.isInteger ? json.get!long : defaultValue;
}
// #endregion getLong

// #region getSize
size_t getSize(Json json, string key, size_t defaultValue = 0) {
  return key in json && json[key].isInteger ? json[key].get!size_t : defaultValue;
}

size_t getSize(Json[string] json, string key, size_t defaultValue = 0) {
  Json value = json.get(key, Json(defaultValue));
  return value.isInteger ? value.get!size_t : defaultValue;
}

size_t getSize(Json json, size_t defaultValue = 0) {
  return json.isInteger ? json.get!size_t : defaultValue;
}
// #endregion getSize

TenantId getTenantId(Json json, string key) {
  return TenantId(key in json && json[key].isString ? json[key].get!string : "");
}

TenantId getTenantId(HTTPServerRequest req) {
  return TenantId(req.headers.get("X-Tenant-Id", ""));
}