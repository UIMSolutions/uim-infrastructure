module uim.infrastructure.terraform.application.dto.terraform_command;


struct TerraformCommand {
    string workspace;
    string modulePath;
    string[string] variables;
    bool autoApprove;
}
