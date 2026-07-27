/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.service.application.dto;

@safe:
struct CommandResult {
  bool success;
  string id;
  string error;
  // TODO: Success??
  bool isSuccess() const {
    return error.length == 0;
  }
}

// struct CommandResult {
//   bool success;
//   string id;
//   string error;
// }
