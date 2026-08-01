module uim.infrastructure.acdoca_service.infrastructure.http.controllers.api_controller;

import uim.infrastructure.acdoca_service.application.dto.journal_entry_command :
    CreateJournalEntryCommand;
import uim.infrastructure.acdoca_service.application.usecases.create_journal_entry :
    CreateJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.delete_journal_entry :
    DeleteJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.get_journal_entry :
    GetJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.list_journal_entries :
    ListJournalEntriesUseCase;
import uim.infrastructure.acdoca_service.domain.entities.journal_entry : DebitCreditIndicator,
    JournalEntry;
import uim.infrastructure.acdoca_service.infrastructure.http.security.write_auth_middleware :
    WriteAuthMiddleware;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

struct JournalEntryView {
    string id;
    string companyCode;
    uint fiscalYear;
    uint documentNumber;
    uint lineItem;
    string glAccount;
    string currency;
    double amount;
    string indicator;
    string text;
    string postingDate;
    string createdAt;
}

class ApiController {
    private CreateJournalEntryUseCase createUseCase;
    private ListJournalEntriesUseCase listUseCase;
    private GetJournalEntryUseCase getUseCase;
    private DeleteJournalEntryUseCase deleteUseCase;
    private WriteAuthMiddleware authMiddleware;

    this(
        CreateJournalEntryUseCase createUseCase,
        ListJournalEntriesUseCase listUseCase,
        GetJournalEntryUseCase getUseCase,
        DeleteJournalEntryUseCase deleteUseCase,
        WriteAuthMiddleware authMiddleware
    ) {
        this.createUseCase = createUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
        this.deleteUseCase = deleteUseCase;
        this.authMiddleware = authMiddleware;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/journal-entries", &listEntries);
        router.post("/v1/journal-entries", &createEntry);
        router.get("/v1/journal-entries/*", &getEntry);
        router.delete_("/v1/journal-entries/*", &deleteEntry);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{ \"status\": \"ok\" }", HTTPStatus.ok);
    }

    void listEntries(HTTPServerRequest req, HTTPServerResponse res) {
        JournalEntryView[] views;
        foreach (entry; listUseCase.execute()) {
            views ~= toView(entry);
        }
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void createEntry(HTTPServerRequest req, HTTPServerResponse res) {
        if (!authMiddleware.authorizeWrite(req, res)) {
            return;
        }

        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto command = toCreateCommand(payload);
            auto entry = createUseCase.execute(command);
            writeJson(res, serializeToJsonString(toView(entry)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void getEntry(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/journal-entries/");
        if (id.length == 0) {
            writeJson(res, "{ \"error\": \"expected /v1/journal-entries/<id>\" }", HTTPStatus.badRequest);
            return;
        }

        auto maybe = getUseCase.execute(id);
        if (!maybe.found) {
            writeJson(res, "{ \"error\": \"journal entry not found\" }", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toView(maybe.value)), HTTPStatus.ok);
    }

    void deleteEntry(HTTPServerRequest req, HTTPServerResponse res) {
        if (!authMiddleware.authorizeWrite(req, res)) {
            return;
        }

        auto id = extractId(req.requestPath.to!string, "/v1/journal-entries/");
        if (id.length == 0) {
            writeJson(res, "{ \"error\": \"expected /v1/journal-entries/<id>\" }", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteUseCase.execute(id);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    private CreateJournalEntryCommand toCreateCommand(Json j) {
        CreateJournalEntryCommand command;
        command.companyCode = requiredString(j, "companyCode");
        command.fiscalYear = requiredUInt(j, "fiscalYear");
        command.documentNumber = requiredUInt(j, "documentNumber");
        command.lineItem = requiredUInt(j, "lineItem");
        command.glAccount = requiredString(j, "glAccount");
        command.currency = requiredString(j, "currency");
        command.amount = requiredDouble(j, "amount");
        command.indicator = requiredString(j, "indicator");
        command.text = "text" in j ? j["text"].get!string : "";
        command.postingDate = "postingDate" in j ? j["postingDate"].get!string : "";
        return command;
    }

    private string requiredString(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        auto value = j[key].get!string;
        if (value.length == 0) {
            throw new Exception(key ~ " cannot be empty");
        }
        return value;
    }

    private uint requiredUInt(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        return j[key].get!uint;
    }

    private double requiredDouble(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        return j[key].get!double;
    }

    private JournalEntryView toView(in JournalEntry entry) {
        return JournalEntryView(
            entry.id,
            entry.companyCode,
            entry.fiscalYear,
            entry.documentNumber,
            entry.lineItem,
            entry.glAccount,
            entry.currency,
            entry.amount,
            entry.indicator == DebitCreditIndicator.debit ? "debit" : "credit",
            entry.text,
            entry.postingDate.toISOExtString(),
            entry.createdAt.toISOExtString()
        );
    }

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }
        auto segments = split(requestPath[prefix.length .. $], "/");
        return segments.length > 0 ? segments[0] : "";
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
