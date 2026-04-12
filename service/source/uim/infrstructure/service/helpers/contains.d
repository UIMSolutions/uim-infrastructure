/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.contains;

import uim.platform.service;

mixin(ShowModule!());

@safe:

bool containsTenant(string[] values, string tenantId) {
  return values.any!(v => v == tenantId);
}

bool containsTenant(string[] values, UUID tenantId) {
  auto id = tenantId.toString;
  return values.any!(v => v == id);
}

bool containsTenant(UUID[] ids, UUID tenantId) {
  return ids.any!(id => id == tenantId);
}
