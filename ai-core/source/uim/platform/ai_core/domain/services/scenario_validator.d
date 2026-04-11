/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.services.scenario_validator;

struct ScenarioValidator {
  static bool validateName(string name) {
    return name.length > 0 && name.length <= 256;
  }

  static bool validateId(string id) {
    return id.length > 0 && id.length <= 256;
  }

  static string validate(string id, string name) {
    if (!validateId(id))
      return "Scenario ID must be between 1 and 256 characters";
    if (!validateName(name))
      return "Scenario name must be between 1 and 256 characters";
    return "";
  }
}
