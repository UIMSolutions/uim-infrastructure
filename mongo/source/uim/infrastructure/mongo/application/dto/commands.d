module uim.infrastructure.mongo.application.dto.commands;

import vibe.data.json : Json;

struct InsertDocumentCommand {
    string database;
    string collection;
    Json data;
}

struct UpdateDocumentCommand {
    string database;
    string collection;
    string id;
    Json data;
}

struct DeleteDocumentCommand {
    string database;
    string collection;
    string id;
}

struct FindDocumentQuery {
    string database;
    string collection;
    string id;
}

struct FindDocumentsQuery {
    string database;
    string collection;
    Json filter;
}

struct ListDocumentsQuery {
    string database;
    string collection;
}
