/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.terraform.domain.entities.terraform_execution;


struct TerraformExecutionResult {
    string step;
    int exitCode;
    string stdoutText;
    string stderrText;

    @property bool successful() const {
        return exitCode == 0;
    }
}

struct TerraformRunReport {
    string action;
    string modulePath;
    string workspace;
    TerraformExecutionResult[] steps;

    @property bool successful() const {
        foreach (step; steps) {
            if (!step.successful) {
                return false;
            }
        }
        return true;
    }
}
