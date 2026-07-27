/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module fs_service.application.usecases.delete_file;

import fs_service.application.dto.file_command : DeleteFileCommand;
import fs_service.domain.ports.repositories.file : IFileRepository;

class DeleteFileUseCase {
    private IFileRepository repository;

    this(IFileRepository repository) {
        this.repository = repository;
    }

    void execute(in DeleteFileCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        repository.remove(command.id);
    }
}
