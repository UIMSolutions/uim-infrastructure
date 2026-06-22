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
