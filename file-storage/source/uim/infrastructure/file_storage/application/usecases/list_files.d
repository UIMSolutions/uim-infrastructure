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
