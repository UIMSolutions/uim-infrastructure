module uim.infrastructure.terraform.application.usecases.get_terraform_version;


import uim.infrastructure.terraform.domain.entities.terraform_execution : TerraformExecutionResult;
import uim.infrastructure.terraform.domain.ports.terraform_runner : ITerraformRunner;

class GetTerraformVersionUseCase {
    private ITerraformRunner runner;

    this(ITerraformRunner runner) {
        this.runner = runner;
    }

    TerraformExecutionResult execute() {
        return runner.execute("version", "", ["version"]);
    }
}
