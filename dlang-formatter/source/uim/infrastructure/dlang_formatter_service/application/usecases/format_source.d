module uim.infrastructure.dlang_formatter_service.application.usecases.format_source;

import uim.infrastructure.dlang_formatter_service.application.dto.format_command :
    FormatCommand;
import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatRequest, FormatResult, FormatterProfile;
import uim.infrastructure.dlang_formatter_service.domain.ports.formatter.formatter_gateway :
    IFormatterGateway;

class FormatSourceUseCase {
    private IFormatterGateway formatterGateway;
    private FormatterProfile[string] profiles;

    this(IFormatterGateway formatterGateway, FormatterProfile[] profiles) {
        this.formatterGateway = formatterGateway;
        foreach (profile; profiles) {
            this.profiles[profile.name] = profile;
        }
    }

    FormatResult execute(FormatCommand command) {
        if (command.sourceCode.length == 0) {
            throw new Exception("sourceCode is required");
        }

        auto profileName = command.profile.length == 0 ? "default" : command.profile;
        if (!(profileName in profiles)) {
            throw new Exception("unknown profile: " ~ profileName);
        }

        auto fileName = command.fileName.length == 0 ? "snippet.d" : command.fileName;

        auto request = FormatRequest(command.sourceCode, fileName, profileName);
        return formatterGateway.format(request, profiles[profileName]);
    }
}
