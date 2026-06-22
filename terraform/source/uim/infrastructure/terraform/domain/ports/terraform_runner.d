module uim.infrastructure.terraform.domain.ports.terraform_runner;


import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult;

interface ITerraformRunner {
    TerraformExecutionResult execute(string step, string workingDirectory, string[] arguments);
}
