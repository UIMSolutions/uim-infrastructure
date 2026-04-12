/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.convert;
import uim.platform.service;

mixin(ShowModule!());

@safe:
private Json toJsonArray(string[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}

Json toJsonArray(UIMEntity[] metrics) {
  return metrics.map!(m => m.toJson()).array.toJson;
}

private Json toJsonArray(T)(T[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}
