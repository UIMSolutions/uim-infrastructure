/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.json_utils;

import uim.platform.ai_core;


bool jsonBool(Json j, string key, bool default_ = false) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isBoolean)
    return (*v).get!bool;
  return default_;
}

int jsonInt(Json j, string key, int default_ = 0) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isInteger)
    return cast(int)(*v).get!long;
  return default_;
}



string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[] result;
  foreach (item; *v) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

/// Parse array of [key, value] pairs from JSON array of objects with "key"/"value" fields
string[][] jsonKeyValuePairs(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[][] result;
  foreach (item; *v) {
    if (item.isObject) {
      auto k = item.getString("key");
      auto val = item.getString("value");
      if (k.length > 0)
        result ~= [k, val];
    }
  }
  return result;
}

Json toJsonArray(string[] arr) {
  auto jarr = Json.emptyArray;
  foreach (s; arr)
    jarr ~= Json(s);
  return jarr;
}



string extractIdFromPath(string path) {
  import std.string : lastIndexOf;

  auto idx = lastIndexOf(path, '/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
