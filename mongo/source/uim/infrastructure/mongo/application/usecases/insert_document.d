/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mongo.application.usecases.insert_document;

import uim.infrastructure.mongo.application.dto.commands : InsertDocumentCommand;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;

class InsertDocumentUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    string execute(in InsertDocumentCommand command) {
        enforceCommand(command);
        return repository.insert(command.database, command.collection, command.data);
    }

    private void enforceCommand(in InsertDocumentCommand command) {
        if (command.database.length == 0) {
            throw new Exception("database must not be empty");
        }
        if (command.collection.length == 0) {
            throw new Exception("collection must not be empty");
        }
    }
}
