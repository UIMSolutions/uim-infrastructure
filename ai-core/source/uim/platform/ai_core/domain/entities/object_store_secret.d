/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.object_store_secret;

import uim.platform.ai_core.domain.types;

struct ObjectStoreSecret {
  ObjectStoreSecretId id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string name;
  string type;
  string bucket;
  string region;
  string endpoint;
  string pathPrefix;
  long createdAt;
  long modifiedAt;
}
