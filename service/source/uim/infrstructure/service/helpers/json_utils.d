/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.json_utils;

import uim.platform.service;

mixin(ShowModule!());

@safe:

/// Extract a string field from a Json object.
string jsonStr(Json j, string key) {
  return j.getString(key, "");
}

/// Extract a boolean field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false) {
  return j.getBoolean(key, default_);
}

/// Extract an integer field from a Json object.
long jsonLong(Json j, string key, long default_ = 0) {
  if (!j.isObject)
    return default_;

  auto v = key in j;
  if (v is null)
    return default_;

  if ((*v).type == Json.Type.int_)
    return (*v).get!long;

  return default_;
}

/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0) {
  return cast(int)jsonLong(j, key, default_);
}

/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort)jsonLong(j, key, default_);
}

double jsonDouble(Json j, string key) {
  if (!j.hasKey(key))
    return 0.0;

  auto v = j[key];
  if (v.isFloat)
    return v.get!double;

  if (v.isInteger)
    return cast(double)v.get!long;
  return 0.0;
}
/// Extract a string array from a Json object.
string[] jsonStrArray(Json json, string key) {
  if (!json.hasKey(key) || json[key] == Json(null))
    return null;

  auto v = json[key];
  if (!v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[]);
  result.reserve(arr.length);

  foreach (item; arr) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result[];
}

string[][] jsonKeyValuePairs(Json json, string key) {
  if (!json.hasKey(key))
    return null;

  auto v = json[key];
  if (v == Json(null) || !v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);

  foreach (item; arr) {
    if (item.isObject) {
      if (!item.hasKey("key") || !item.hasKey("value"))
        continue;

      result ~= [item["key"].get!string, item["value"].get!string];
    } else if (item.isArray) {
      auto elems = item.toArray;
      auto pair = appender!(string[]);
      pair.reserve(elems.length);
      foreach (elem; elems) {
        if (elem.isString)
          pair ~= elem.get!string;
      }
      if (pair[].length >= 2)
        result ~= pair[];
    }
  }
  return result[];
}

/// Convert a string array to a Json array. Alias for toJsonArray.
Json stringsToJsonArray(string[] arr) {
  return toJsonArray(arr);
}

string[][] jsonPairArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = j[key];
  if (!v.isArray)
    return [];
  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);
  foreach (elem; arr) {
    if (elem.isObject) {
      auto k = "key" in elem;
      auto val = "value" in elem;
      if (k !is null && val !is null) {
        result ~= [(*k).get!string, (*val).get!string];
      }
    } else if (elem.isArray) {
      auto items = elem.toArray;
      auto pair = appender!(string[]);
      pair.reserve(items.length);
      foreach (item; items) {
        if (item.isString)
          pair ~= item.get!string;
      }
      if (pair[].length >= 2)
        result ~= pair[];
    }
  }
  return result[];
}

string[][] jsonMessageArray(Json j, string key) {
  if (!j.isObject)
    return null;
  auto v = j[key];
  if (!v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);
  foreach (elem; arr) {
    if (elem.isObject) {
      auto role = "role" in elem;
      auto content = "content" in elem;
      if (role !is null && content !is null) {
        result ~= [(*role).get!string, (*content).get!string];
      }
    }
  }
  return result[];
}
/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
  import std.string : lastIndexOf, indexOf;

  // Strip query string
  auto qpos = uri.indexOf('?');
  string path = qpos >= 0 ? uri[0 .. qpos] : uri;

  // Strip trailing slash
  if (path.length > 0 && path[$ - 1] == '/')
    path = path[0 .. $ - 1];

  // Find last slash
  auto spos = path.lastIndexOf('/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
  auto error = Json.emptyObject;
  error["error"] = Json(message);
  error["status"] = Json(status);
  // j["code"] = Json(code);
  res.writeJsonBody(error, status);
}

/* void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json.emptyObject;
  j["error"]["message"] = Json(message);
  j["error"]["code"] = Json(status);
  res.writeJsonBody(j, status);
} */

/// Alias for extractIdFromPath (without query-string stripping).
string extractIdFromPath2(string path) {
  return extractIdFromPath(path);
}
///
unittest {
  assert(extractIdFromPath("/v1/tenants/abc123") == "abc123");
  assert(extractIdFromPath("/v1/tenants/abc123/") == "abc123");
  assert(extractIdFromPath("/v1/tenants/abc123?foo=bar") == "abc123");
  assert(extractIdFromPath("single") == "single");

  assert(jsonStr(parseJsonString(`{"name": "test"}`), "name") == "test");
  assert(jsonStr(parseJsonString(`{"name": "test"}`), "missing") == "");

  assert(jsonStrArray(parseJsonString(`{"tags": ["a", "b"]}`), "tags") == ["a", "b"]);
  assert(jsonStrArray(parseJsonString(`{}`), "tags") is null);
}

Json toJsonArray(string[] arr) {
  return arr.map!(s => Json(s)).array.Json;
}

string[string] jsonStrMap(Json j, string key) {
  if (!j.isObject)
    return null;

  auto v = j[key];
  if (!v.isObject)
    return null;

  string[string] result;
  foreach (string k, val; v.toMap) {
    if (val.isString)
      result[k] = val.get!string;
  }
  return result;
}

string extractId(string uri) {
  // import std.string : lastIndexOf;
  auto idx = uri.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < uri.length)
    return uri[idx + 1 .. $];
  return "";
}

/*

private string extractId(scope HTTPServerRequest req) {
  // import std.conv : to;
  // import std.string : split;
  auto path = req.requestURI;
  auto parts = path.split("/");
  // /api/v1/dashboards/{id}...
  foreach (i, part; parts) {
    if (part == "dashboards" && i + 1 < parts.length) {
      auto candidate = parts[i + 1];
      // Skip sub-resource keywords
      if (candidate != "publish" && candidate != "pages" && candidate.length > 0)
        return candidate;
    }
  }
  return "";
}

*/


/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort) jsonLong(j, key, default_);
}

/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
  auto j = Json.emptyArray;
  foreach (s; arr)
    j ~= Json(s);
  return j;
}
