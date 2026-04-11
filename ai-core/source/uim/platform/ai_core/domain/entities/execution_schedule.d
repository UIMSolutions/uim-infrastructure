/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.execution_schedule;

import uim.platform.ai_core.domain.types;

struct ExecutionSchedule {
  string id;
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  string name;
  string cron;
  ScheduleStatus status;
  long start;
  long end;
  long createdAt;
  long modifiedAt;
}
