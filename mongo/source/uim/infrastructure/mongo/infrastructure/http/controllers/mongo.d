module uim.infrastructure.mongo.infrastructure.http.controllers.mongo;

import uim.infrastructure.mongo.application.dto.commands;
import uim.infrastructure.mongo.application.usecases.insert_document : InsertDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.find_document : FindDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.find_documents : FindDocumentsUseCase;
import uim.infrastructure.mongo.application.usecases.list_documents : ListDocumentsUseCase;
import uim.infrastructure.mongo.application.usecases.update_document : UpdateDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.delete_document : DeleteDocumentUseCase;
import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

struct DocumentView {
    string id;
    string database;
    string collection;
    string data;
}

class MongoController {
    private InsertDocumentUseCase insertUseCase;
    private FindDocumentUseCase findUseCase;
    private FindDocumentsUseCase findDocsUseCase;
    private ListDocumentsUseCase listUseCase;
    private UpdateDocumentUseCase updateUseCase;
    private DeleteDocumentUseCase deleteUseCase;

    this(
        InsertDocumentUseCase insertUseCase,
        FindDocumentUseCase findUseCase,
        FindDocumentsUseCase findDocsUseCase,
        ListDocumentsUseCase listUseCase,
        UpdateDocumentUseCase updateUseCase,
        DeleteDocumentUseCase deleteUseCase,
    ) {
        this.insertUseCase = insertUseCase;
        this.findUseCase = findUseCase;
        this.findDocsUseCase = findDocsUseCase;
        this.listUseCase = listUseCase;
        this.updateUseCase = updateUseCase;
        this.deleteUseCase = deleteUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/documents/*", &handleGet);
        router.post("/v1/documents/*", &handlePost);
        router.put("/v1/documents/*", &handlePut);
        router.delete_("/v1/documents/*", &handleDelete);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // --- GET /v1/documents/<db>/<collection> --- list
    // --- GET /v1/documents/<db>/<collection>/<id> --- find by id

    void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/documents/");

        if (segments.length == 2) {
            listDocuments(res, segments[0], segments[1]);
        } else if (segments.length == 3) {
            findDocument(res, segments[0], segments[1], segments[2]);
        } else {
            writeJson(res, `{ "error": "expected /v1/documents/<db>/<collection> or /v1/documents/<db>/<collection>/<id>" }`, HTTPStatus.badRequest);
        }
    }

    // --- POST /v1/documents/<db>/<collection> --- insert (body = JSON document)

    void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/documents/");
        if (segments.length != 2) {
            writeJson(res, `{ "error": "expected /v1/documents/<db>/<collection>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto body = req.json;
            auto command = InsertDocumentCommand(segments[0], segments[1], body);
            auto id = insertUseCase.execute(command);

            auto response = Json.emptyObject;
            response["id"] = id;
            response["database"] = segments[0];
            response["collection"] = segments[1];
            writeJson(res, response.to!string, HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- PUT /v1/documents/<db>/<collection>/<id> --- update (body = JSON document)

    void handlePut(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/documents/");
        if (segments.length != 3) {
            writeJson(res, `{ "error": "expected /v1/documents/<db>/<collection>/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto body = req.json;
            auto command = UpdateDocumentCommand(segments[0], segments[1], segments[2], body);
            auto ok = updateUseCase.execute(command);
            if (ok) {
                writeJson(res, `{ "status": "updated" }`, HTTPStatus.ok);
            } else {
                writeJson(res, `{ "error": "document not found" }`, HTTPStatus.notFound);
            }
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- DELETE /v1/documents/<db>/<collection>/<id> --- delete

    void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/documents/");
        if (segments.length != 3) {
            writeJson(res, `{ "error": "expected /v1/documents/<db>/<collection>/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = DeleteDocumentCommand(segments[0], segments[1], segments[2]);
            auto ok = deleteUseCase.execute(command);
            if (ok) {
                writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
            } else {
                writeJson(res, `{ "error": "document not found" }`, HTTPStatus.notFound);
            }
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- Helpers ---

    private void listDocuments(HTTPServerResponse res, string db, string coll) {
        try {
            auto query = ListDocumentsQuery(db, coll);
            auto docs = listUseCase.execute(query);
            writeJson(res, serializeToJsonString(documentsToViews(docs)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private void findDocument(HTTPServerResponse res, string db, string coll, string id) {
        try {
            auto query = FindDocumentQuery(db, coll, id);
            auto doc = findUseCase.execute(query);
            if (doc.id.length == 0) {
                writeJson(res, `{ "error": "document not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(documentToView(doc)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private DocumentView documentToView(in MongoDocument doc) {
        return DocumentView(doc.id, doc.database, doc.collection, doc.data.to!string);
    }

    private DocumentView[] documentsToViews(in MongoDocument[] docs) {
        DocumentView[] views;
        foreach (doc; docs) {
            views ~= documentToView(doc);
        }
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        auto remainder = requestPath[prefix.length .. $];
        return split(remainder, "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int)status, "application/json");
    }
}
