/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.services.execution_scheduler;

import uim.platform.ai_core.domain.types;

struct ExecutionScheduler {
  static bool isValidCron(string cron) {
    import std.array : split;
    auto parts = cron.split(" ");
    return parts.length == 5;
  }

  static bool canTransition(ExecutionStatus from, TargetStatus to) {
    if (to == TargetStatus.stopped) {
      return from == ExecutionStatus.running || from == ExecutionStatus.pending;
    }
    if (to == TargetStatus.deleted_) {
      return from != ExecutionStatus.dead;
    }
    return false;
  }

  static bool canTransitionDeployment(DeploymentStatus from, TargetStatus to) {
    if (to == TargetStatus.stopped) {
      return from == DeploymentStatus.running || from == DeploymentStatus.pending;
    }
    if (to == TargetStatus.running) {
      return from == DeploymentStatus.stopped;
    }
    if (to == TargetStatus.deleted_) {
      return from != DeploymentStatus.dead;
    }
    return false;
  }
}
