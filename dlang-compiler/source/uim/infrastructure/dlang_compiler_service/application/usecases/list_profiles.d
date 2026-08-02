module uim.infrastructure.dlang_compiler_service.application.usecases.list_profiles;

import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompilerProfile;

class ListProfilesUseCase {
    private CompilerProfile[] profiles;

    this(CompilerProfile[] profiles) {
        this.profiles = profiles.dup;
    }

    CompilerProfile[] execute() {
        return profiles.dup;
    }
}
