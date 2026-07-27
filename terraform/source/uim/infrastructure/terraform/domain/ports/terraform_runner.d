/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.terraform.domain.ports.terraform_runner;


import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult;

interface ITerraformRunner {
    TerraformExecutionResult execute(string step, string workingDirectory, string[] arguments);
}
