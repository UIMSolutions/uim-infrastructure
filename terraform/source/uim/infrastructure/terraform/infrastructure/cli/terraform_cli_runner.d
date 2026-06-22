module uim.infrastructure.terraform.infrastructure.cli.terraform_cli_runner;

import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult;
import uim.infrastructure.terraform.domain.ports.terraform_runner : ITerraformRunner;
import std.process : stdProcessExecute = execute;

class TerraformCliRunner : ITerraformRunner {
    private string terraformBinary;

    this(string terraformBinary) {
        this.terraformBinary = terraformBinary.length == 0 ? "terraform" : terraformBinary;
    }

    override TerraformExecutionResult execute(string step, string workingDirectory, string[] arguments) {
        string[] cmd = [terraformBinary];
        if (workingDirectory.length > 0) {
            cmd ~= "-chdir=" ~ workingDirectory;
        }
        cmd ~= arguments;

        try {
            auto result = stdProcessExecute(cmd);
            return TerraformExecutionResult(
                step,
                result.status,
                cast(string) result.output,
                ""
            );
        } catch (Exception ex) {
            return TerraformExecutionResult(step, 1, "", ex.msg);
        }
    }
}