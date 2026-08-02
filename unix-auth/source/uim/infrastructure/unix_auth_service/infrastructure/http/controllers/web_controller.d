module uim.infrastructure.unix_auth_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.unix_auth_service.application.dto.create_user_command :
    CreateUserCommand;
import uim.infrastructure.unix_auth_service.application.dto.password_command :
    GenerateHashCommand, SetPasswordCommand;
import uim.infrastructure.unix_auth_service.application.usecases.create_user :
    CreateUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.generate_hash :
    GenerateHashUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.get_user : GetUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.list_users : ListUsersUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.set_password :
    SetPasswordUseCase;
import uim.infrastructure.unix_auth_service.domain.entities.unix_user : UnixUser;
import uim.infrastructure.unix_auth_service.infrastructure.http.views.html_renderer :
    HtmlRenderer;
import std.conv : to;
import std.string : replace, split, startsWith, strip, toLower;
import std.uri : decodeComponent;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private ListUsersUseCase listUsersUseCase;
    private GetUserUseCase getUserUseCase;
    private CreateUserUseCase createUserUseCase;
    private SetPasswordUseCase setPasswordUseCase;
    private GenerateHashUseCase generateHashUseCase;
    private HtmlRenderer renderer;

    this(
        ListUsersUseCase listUsersUseCase,
        GetUserUseCase getUserUseCase,
        CreateUserUseCase createUserUseCase,
        SetPasswordUseCase setPasswordUseCase,
        GenerateHashUseCase generateHashUseCase
    ) {
        this.listUsersUseCase = listUsersUseCase;
        this.getUserUseCase = getUserUseCase;
        this.createUserUseCase = createUserUseCase;
        this.setPasswordUseCase = setPasswordUseCase;
        this.generateHashUseCase = generateHashUseCase;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);
        router.get("/users", &home);
        router.get("/users/new", &newUserForm);
        router.post("/users/new", &newUserSubmit);
        router.get("/users/*", &userDetail);
        router.post("/users/*", &userAction);
        router.get("/hash", &hashToolForm);
        router.post("/hash", &hashToolSubmit);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(listUsersUseCase.execute()), HTTPStatus.ok);
    }

    void newUserForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCreateUserForm(), HTTPStatus.ok);
    }

    void newUserSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto command = CreateUserCommand(
                form.get("username", "").strip,
                form.get("uid", "0").to!uint,
                form.get("gid", "0").to!uint,
                form.get("gecos", "").strip,
                form.get("homeDirectory", "").strip,
                form.get("loginShell", "").strip,
                form.get("password", "")
            );

            auto created = createUserUseCase.execute(command);
            writeHtml(
                res,
                renderer.renderCreateUserForm("", "Created user " ~ created.passwd.username),
                HTTPStatus.created
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderCreateUserForm(ex.msg, ""), HTTPStatus.badRequest);
        }
    }

    void userDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto username = extractId(req.requestPath.to!string, "/users/");
        if (username.length == 0) {
            writeHtml(res, renderer.renderNotFound("User path is invalid"), HTTPStatus.notFound);
            return;
        }

        auto maybe = getUserUseCase.execute(username);
        if (!maybe.found) {
            writeHtml(res, renderer.renderNotFound("User not found"), HTTPStatus.notFound);
            return;
        }

        writeHtml(
            res,
            renderer.renderUserDetail(maybe.value, serializeToJsonString(toPreview(maybe.value))),
            HTTPStatus.ok
        );
    }

    void userAction(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractRest(req.requestPath.to!string, "/users/");
        auto parts = rest.split("/");

        if (parts.length == 2 && parts[1] == "password") {
            auto username = parts[0];
            auto maybe = getUserUseCase.execute(username);
            if (!maybe.found) {
                writeHtml(res, renderer.renderNotFound("User not found"), HTTPStatus.notFound);
                return;
            }

            try {
                auto form = parseForm(req.bodyReader.readAllUTF8());
                auto command = SetPasswordCommand(
                    username,
                    form.get("password", ""),
                    form.get("algorithm", "sha512").toLower.strip
                );

                auto updated = setPasswordUseCase.execute(command);
                writeHtml(
                    res,
                    renderer.renderUserDetail(
                        updated,
                        serializeToJsonString(toPreview(updated)),
                        "",
                        "Password hash updated"
                    ),
                    HTTPStatus.ok
                );
                return;
            } catch (Exception ex) {
                writeHtml(
                    res,
                    renderer.renderUserDetail(maybe.value, serializeToJsonString(toPreview(maybe.value)), ex.msg, ""),
                    HTTPStatus.badRequest
                );
                return;
            }
        }

        writeHtml(res, renderer.renderNotFound("Unsupported action"), HTTPStatus.notFound);
    }

    void hashToolForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHashTool(), HTTPStatus.ok);
    }

    void hashToolSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto result = generateHashUseCase.execute(
                GenerateHashCommand(
                    form.get("password", ""),
                    form.get("algorithm", "sha512").toLower.strip,
                    ""
                )
            );

            writeHtml(
                res,
                renderer.renderHashTool("", "Hash generated", result.hash, result.salt),
                HTTPStatus.ok
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderHashTool(ex.msg), HTTPStatus.badRequest);
        }
    }

    private struct UserPreview {
        string username;
        uint uid;
        uint gid;
        string homeDirectory;
        string loginShell;
        bool hasShadow;
        string passwordHash;
    }

    private UserPreview toPreview(UnixUser user) {
        return UserPreview(
            user.passwd.username,
            user.passwd.uid,
            user.passwd.gid,
            user.passwd.homeDirectory,
            user.passwd.loginShell,
            user.hasShadow,
            user.hasShadow ? user.shadow.passwordHash : ""
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
        auto rest = extractRest(requestPath, prefix);
        auto parts = rest.split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private string extractRest(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        return requestPath[prefix.length .. $];
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
