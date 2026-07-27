/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module fs_service.application.usecases.list_files;

import fs_service.domain.entities.stored_file : StoredFile;
import fs_service.domain.ports.repositories.file : IFileRepository;

class ListFilesUseCase {
    private IFileRepository repository;

    this(IFileRepository repository) {
        this.repository = repository;
    }

    StoredFile[] execute() {
        return repository.list();
    }
}
