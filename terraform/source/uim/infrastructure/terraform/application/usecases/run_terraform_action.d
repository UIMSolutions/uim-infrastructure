/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.terraform.application.usecases.run_terraform_action;


import uim.infrastructure.terraform.application.dto.terraform_command : TerraformCommand;
import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult, TerraformRunReport;
import uim.infrastructure.terraform.domain.ports.terraform_runner : ITerraformRunner;
import std.algorithm.sorting : sort;
import std.array : array;
import std.string : strip, toLower;

enum TerraformAction {
    validate,
    plan,
    apply,
    destroy_
}

class RunTerraformActionUseCase {
    private ITerraformRunner runner;
    private string defaultModulePath;
    private bool defaultAutoApprove;

    this(ITerraformRunner runner, string defaultModulePath, bool defaultAutoApprove) {
        this.runner = runner;
        this.defaultModulePath = defaultModulePath;
        this.defaultAutoApprove = defaultAutoApprove;
    }

    TerraformRunReport execute(TerraformAction action, in TerraformCommand command) {
        auto modulePath = effectiveModulePath(command);
        auto workspace = command.workspace.strip();

        TerraformExecutionResult[] steps;

        steps ~= runner.execute("init", modulePath, ["init", "-input=false", "-no-color"]);
        if (!steps[$ - 1].successful) {
            return TerraformRunReport(actionToString(action), modulePath, workspace, steps);
        }

        if (workspace.length > 0) {
            auto selectResult = runner.execute(
                "workspace-select",
                modulePath,
                ["workspace", "select", workspace]
            );

            if (!selectResult.successful) {
                auto createResult = runner.execute(
                    "workspace-new",
                    modulePath,
                    ["workspace", "new", workspace]
                );
                steps ~= createResult;
                if (!createResult.successful) {
                    return TerraformRunReport(actionToString(action), modulePath, workspace, steps);
                }
            } else {
                steps ~= selectResult;
            }
        }

        steps ~= runner.execute(actionToString(action), modulePath, buildActionArguments(action, command));

        return TerraformRunReport(actionToString(action), modulePath, workspace, steps);
    }

    private string effectiveModulePath(in TerraformCommand command) {
        auto configured = command.modulePath.strip();
        return configured.length == 0 ? defaultModulePath : configured;
    }

    private string[] buildActionArguments(TerraformAction action, in TerraformCommand command) {
        string[] args;

        final switch (action) {
            case TerraformAction.validate:
                args = ["validate", "-no-color"];
                break;
            case TerraformAction.plan:
                args = ["plan", "-input=false", "-no-color"];
                break;
            case TerraformAction.apply:
                args = ["apply", "-input=false", "-no-color"];
                if (effectiveAutoApprove(command)) {
                    args ~= "-auto-approve";
                }
                break;
            case TerraformAction.destroy_:
                args = ["destroy", "-input=false", "-no-color"];
                if (effectiveAutoApprove(command)) {
                    args ~= "-auto-approve";
                }
                break;
        }

        auto keys = command.variables.keys.array;
        sort(keys);

        foreach (k; keys) {
            args ~= "-var=" ~ k ~ "=" ~ command.variables[k];
        }

        return args;
    }

    private bool effectiveAutoApprove(in TerraformCommand command) {
        return command.autoApprove || defaultAutoApprove;
    }

    private string actionToString(TerraformAction action) {
        final switch (action) {
            case TerraformAction.validate:
                return "validate";
            case TerraformAction.plan:
                return "plan";
            case TerraformAction.apply:
                return "apply";
            case TerraformAction.destroy_:
                return "destroy";
        }
    }
}
