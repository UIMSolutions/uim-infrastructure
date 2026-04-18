module uim.infrastructure.database.infrastructure.http.controllers.database;

import uim.infrastructure.database.application.dto.commands;
import uim.infrastructure.database.application.usecases.insert_row : InsertRowUseCase;
import uim.infrastructure.database.application.usecases.find_row : FindRowUseCase;
import uim.infrastructure.database.application.usecases.find_rows : FindRowsUseCase;
import uim.infrastructure.database.application.usecases.list_rows : ListRowsUseCase;
import uim.infrastructure.database.application.usecases.update_row : UpdateRowUseCase;
import uim.infrastructure.database.application.usecases.delete_row : DeleteRowUseCase;
import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

/// JSON view projected from a DatabaseRow for HTTP responses.
struct RowView {
    string id;
    string schema;
    string table;
    string data;
}

/**
 * HTTP controller for the database service.
 *
 * Routes (all under /v1/rows):
 *   GET    /health                             — liveness probe
 *   GET    /v1/rows/<schema>/<table>           — list all rows
 *   GET    /v1/rows/<schema>/<table>/<id>      — find row by id
 *   POST   /v1/rows/<schema>/<table>           — insert row  (body: JSON object)
 *   PUT    /v1/rows/<schema>/<table>/<id>      — update row  (body: JSON object)
 *   DELETE /v1/rows/<schema>/<table>/<id>      — delete row
 *
 * Filter queries:
 *   POST   /v1/rows/<schema>/<table>/filter    — find rows matching body filter
 */
class DatabaseController {
    private InsertRowUseCase insertUseCase;
    private FindRowUseCase findUseCase;
    private FindRowsUseCase findRowsUseCase;
    private ListRowsUseCase listUseCase;
    private UpdateRowUseCase updateUseCase;
    private DeleteRowUseCase deleteUseCase;

    this(
        InsertRowUseCase insertUseCase,
        FindRowUseCase findUseCase,
        FindRowsUseCase findRowsUseCase,
        ListRowsUseCase listUseCase,
        UpdateRowUseCase updateUseCase,
        DeleteRowUseCase deleteUseCase,
    ) {
        this.insertUseCase = insertUseCase;
        this.findUseCase = findUseCase;
        this.findRowsUseCase = findRowsUseCase;
        this.listUseCase = listUseCase;
        this.updateUseCase = updateUseCase;
        this.deleteUseCase = deleteUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/rows/*", &handleGet);
        router.post("/v1/rows/*", &handlePost);
        router.put("/v1/rows/*", &handlePut);
        router.delete_("/v1/rows/*", &handleDelete);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // --- GET /v1/rows/<schema>/<table>        — list
    // --- GET /v1/rows/<schema>/<table>/<id>   — find by id

    void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPath(req.requestPath.to!string, "/v1/rows/");

        if (segments.length == 2) {
            listRows(res, segments[0], segments[1]);
        } else if (segments.length == 3) {
            findRow(res, segments[0], segments[1], segments[2]);
        } else {
            writeJson(res,
                `{ "error": "expected /v1/rows/<schema>/<table> or /v1/rows/<schema>/<table>/<id>" }`,
                HTTPStatus.badRequest);
        }
    }

    // --- POST /v1/rows/<schema>/<table>          — insert
    // --- POST /v1/rows/<schema>/<table>/filter   — filter query

    void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPath(req.requestPath.to!string, "/v1/rows/");

        if (segments.length == 3 && segments[2] == "filter") {
            filterRows(res, segments[0], segments[1], req.json);
            return;
        }

        if (segments.length != 2) {
            writeJson(res,
                `{ "error": "expected /v1/rows/<schema>/<table> or /v1/rows/<schema>/<table>/filter" }`,
                HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = InsertRowCommand(segments[0], segments[1], req.json);
            auto id = insertUseCase.execute(command);

            auto response = Json.emptyObject;
            response["id"] = id;
            response["schema"] = segments[0];
            response["table"] = segments[1];
            writeJson(res, response.to!string, HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- PUT /v1/rows/<schema>/<table>/<id>  — update

    void handlePut(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPath(req.requestPath.to!string, "/v1/rows/");
        if (segments.length != 3) {
            writeJson(res, `{ "error": "expected /v1/rows/<schema>/<table>/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = UpdateRowCommand(segments[0], segments[1], segments[2], req.json);
            auto ok = updateUseCase.execute(command);
            if (ok) {
                writeJson(res, `{ "status": "updated" }`, HTTPStatus.ok);
            } else {
                writeJson(res, `{ "error": "row not found" }`, HTTPStatus.notFound);
            }
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- DELETE /v1/rows/<schema>/<table>/<id>  — delete

    void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPath(req.requestPath.to!string, "/v1/rows/");
        if (segments.length != 3) {
            writeJson(res, `{ "error": "expected /v1/rows/<schema>/<table>/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = DeleteRowCommand(segments[0], segments[1], segments[2]);
            auto ok = deleteUseCase.execute(command);
            if (ok) {
                writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
            } else {
                writeJson(res, `{ "error": "row not found" }`, HTTPStatus.notFound);
            }
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- Helpers ---

    private void listRows(HTTPServerResponse res, string schema, string table) {
        try {
            auto query = ListRowsQuery(schema, table);
            auto rows = listUseCase.execute(query);
            writeJson(res, serializeToJsonString(rowsToViews(rows)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.internalServerError);
        }
    }

    private void findRow(HTTPServerResponse res, string schema, string table, string id) {
        try {
            auto query = FindRowQuery(schema, table, id);
            auto row = findUseCase.execute(query);
            if (row.id.length == 0) {
                writeJson(res, `{ "error": "row not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(rowToView(row)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.internalServerError);
        }
    }

    private void filterRows(HTTPServerResponse res, string schema, string table, Json filter) {
        try {
            auto query = FindRowsQuery(schema, table, filter);
            auto rows = findRowsUseCase.execute(query);
            writeJson(res, serializeToJsonString(rowsToViews(rows)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.internalServerError);
        }
    }

    private RowView rowToView(in DatabaseRow row) {
        return RowView(row.id, row.schema, row.table, row.data.to!string);
    }

    private RowView[] rowsToViews(in DatabaseRow[] rows) {
        RowView[] views;
        foreach (row; rows) {
            views ~= rowToView(row);
        }
        return views;
    }

    private string[] splitPath(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        auto remainder = requestPath[prefix.length .. $];
        return split(remainder, "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
