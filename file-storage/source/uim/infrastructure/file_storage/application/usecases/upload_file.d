module fs_service.application.usecases.upload_file;

import fs_service.application.dto.file_command : UploadFileCommand;
import fs_service.domain.entities.stored_file : StoredFile;
import fs_service.domain.ports.repositories.file : IFileRepository;
import std.datetime : Clock;
import std.uuid : randomUUID;

class UploadFileUseCase {
    private IFileRepository repository;

    this(IFileRepository repository) {
        this.repository = repository;
    }

    StoredFile execute(in UploadFileCommand command) {
        enforceCommand(command);

        auto file = StoredFile(
            randomUUID().toString(),
            command.name,
            command.contentType,
            command.data.length,
            Clock.currTime(),
            command.data.dup
        );

        repository.save(file);
        return file;
    }

    private void enforceCommand(in UploadFileCommand command) {
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.contentType.length == 0) {
            throw new Exception("contentType must not be empty");
        }
        if (command.data.length == 0) {
            throw new Exception("file data must not be empty");
        }
    }
}
