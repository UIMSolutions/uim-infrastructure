/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.resource_group;

import uim.platform.ai_core.domain.types;

struct ResourceGroupLabel {
  string key;
  string value;
}

struct ResourceGroup {
  ResourceGroupId id;
  TenantId tenantId;
  string status;
  ResourceGroupLabel[] labels;
  long createdAt;
}
