module uim.infrastructure.acdoca_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.acdoca_service.application.dto.journal_entry_command :
    CreateJournalEntryCommand;
import uim.infrastructure.acdoca_service.application.usecases.create_journal_entry :
    CreateJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.get_journal_entry :
    GetJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.list_journal_entries :
    ListJournalEntriesUseCase;
import uim.infrastructure.acdoca_service.domain.entities.journal_entry : JournalEntry;
import uim.infrastructure.acdoca_service.infrastructure.http.security.write_auth_middleware :
    WriteAuthMiddleware;
import uim.infrastructure.acdoca_service.infrastructure.http.views.html_renderer : HtmlRenderer;
import std.conv : to;
import std.string : replace, split, startsWith, strip, toLower;
import std.uri : decodeComponent;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private CreateJournalEntryUseCase createUseCase;
    private ListJournalEntriesUseCase listUseCase;
    private GetJournalEntryUseCase getUseCase;
    private HtmlRenderer renderer;
    private string defaultCompanyCode;
    private WriteAuthMiddleware authMiddleware;

    this(
        CreateJournalEntryUseCase createUseCase,
        ListJournalEntriesUseCase listUseCase,
        GetJournalEntryUseCase getUseCase,
        string defaultCompanyCode,
        WriteAuthMiddleware authMiddleware
    ) {
        this.createUseCase = createUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
        this.defaultCompanyCode = defaultCompanyCode;
        this.authMiddleware = authMiddleware;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/entries", &home);
        router.get("/entries/new", &newEntryForm);
        router.post("/entries/new", &newEntrySubmit);
        router.get("/entries/*", &entryDetail);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(listUseCase.execute()), HTTPStatus.ok);
    }

    void newEntryForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCreateForm(defaultCompanyCode), HTTPStatus.ok);
    }

    void newEntrySubmit(HTTPServerRequest req, HTTPServerResponse res) {
        if (!authMiddleware.authorizeWrite(req, res)) {
            return;
        }

        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto command = toCreateCommand(form);
            auto entry = createUseCase.execute(command);

            writeHtml(
                res,
                renderer.renderCreateForm(
                    defaultCompanyCode,
                    "",
                    "Created journal entry " ~ entry.id
                ),
                HTTPStatus.created
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderCreateForm(defaultCompanyCode, ex.msg), HTTPStatus.badRequest);
        }
    }

    void entryDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/entries/");
        if (id.length == 0) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        auto maybe = getUseCase.execute(id);
        if (!maybe.found) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        writeHtml(
            res,
            renderer.renderEntryDetail(maybe.value, serializeToJsonString(toPreview(maybe.value))),
            HTTPStatus.ok
        );
    }

    private CreateJournalEntryCommand toCreateCommand(string[string] form) {
        CreateJournalEntryCommand command;
        command.companyCode = form.get("companyCode", "").strip;
        command.fiscalYear = form.get("fiscalYear", "0").to!uint;
        command.documentNumber = form.get("documentNumber", "0").to!uint;
        command.lineItem = form.get("lineItem", "0").to!uint;
        command.glAccount = form.get("glAccount", "").strip;
        command.currency = form.get("currency", "").strip;
        command.amount = form.get("amount", "0").to!double;
        command.indicator = form.get("indicator", "debit").toLower;
        command.text = form.get("text", "").strip;
        command.postingDate = form.get("postingDate", "").strip;
        return command;
    }

    private struct EntryPreview {
        string id;
        string companyCode;
        uint fiscalYear;
        uint documentNumber;
        uint lineItem;
        string glAccount;
        string currency;
        double amount;
        string indicator;
        string postingDate;
        string text;
    }

    private EntryPreview toPreview(in JournalEntry entry) {
        return EntryPreview(
            entry.id,
            entry.companyCode,
            entry.fiscalYear,
            entry.documentNumber,
            entry.lineItem,
            entry.glAccount,
            entry.currency,
            entry.amount,
            entry.indicator.to!string,
            entry.postingDate.toISOExtString(),
            entry.text
        );
    }

    private string[string] parseForm(string body) {
        string[string] result;

        foreach (pair; body.split("&")) {
            if (pair.length == 0) {
                continue;
            }

            auto parts = pair.split("=");
            auto key = decodeForm(parts.length > 0 ? parts[0] : "");
            auto value = decodeForm(parts.length > 1 ? parts[1] : "");
            result[key] = value;
        }

        return result;
    }

    private string decodeForm(string value) {
        return decodeComponent(value.replace("+", " "));
    }

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        auto parts = requestPath[prefix.length .. $].split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
