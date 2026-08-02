module uim.infrastructure.dlang_formatter_service.application.usecases.list_profiles;

import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatterProfile;

class ListProfilesUseCase {
    private FormatterProfile[] profiles;

    this(FormatterProfile[] profiles) {
        this.profiles = profiles.dup;
    }

    FormatterProfile[] execute() {
        return profiles.dup;
    }
}
