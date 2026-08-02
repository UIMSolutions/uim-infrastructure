module uim.infrastructure.unix_auth_service.infrastructure.http.controllers.api_controller;

import uim.infrastructure.unix_auth_service.application.dto.create_user_command :
    CreateUserCommand;
import uim.infrastructure.unix_auth_service.application.dto.password_command :
    GenerateHashCommand, SetPasswordCommand, VerifyPasswordCommand;
import uim.infrastructure.unix_auth_service.application.usecases.create_user :
    CreateUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.generate_hash :
    GenerateHashUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.get_user : GetUserUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.list_users : ListUsersUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.set_password :
    SetPasswordUseCase;
import uim.infrastructure.unix_auth_service.application.usecases.verify_password :
    VerifyPasswordUseCase;
import uim.infrastructure.unix_auth_service.domain.entities.unix_user : UnixUser;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

struct UnixUserView {
    string username;
    uint uid;
    uint gid;
    string gecos;
    string homeDirectory;
    string loginShell;
    bool hasShadow;
    bool locked;
    string passwordHash;
    long lastChangeDay;
}

class ApiController {
    private ListUsersUseCase listUsersUseCase;
    private GetUserUseCase getUserUseCase;
    private CreateUserUseCase createUserUseCase;
    private SetPasswordUseCase setPasswordUseCase;
    private GenerateHashUseCase generateHashUseCase;
    private VerifyPasswordUseCase verifyPasswordUseCase;

    this(
        ListUsersUseCase listUsersUseCase,
        GetUserUseCase getUserUseCase,
        CreateUserUseCase createUserUseCase,
        SetPasswordUseCase setPasswordUseCase,
        GenerateHashUseCase generateHashUseCase,
        VerifyPasswordUseCase verifyPasswordUseCase
    ) {
        this.listUsersUseCase = listUsersUseCase;
        this.getUserUseCase = getUserUseCase;
        this.createUserUseCase = createUserUseCase;
        this.setPasswordUseCase = setPasswordUseCase;
        this.generateHashUseCase = generateHashUseCase;
        this.verifyPasswordUseCase = verifyPasswordUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        router.get("/v1/unix/users", &listUsers);
        router.get("/v1/unix/users/*", &getUser);
        router.post("/v1/unix/users", &createUser);
        router.post("/v1/unix/users/*", &userAction);

        router.post("/v1/unix/hash", &generateHash);
        router.post("/v1/unix/verify", &verifyPassword);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{ \"status\": \"ok\", \"service\": \"uim-unix-auth-service\" }", HTTPStatus.ok);
    }

    void listUsers(HTTPServerRequest req, HTTPServerResponse res) {
        UnixUserView[] views;
        foreach (user; listUsersUseCase.execute()) {
            views ~= toView(user);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto username = extractId(req.requestPath.to!string, "/v1/unix/users/");
        if (username.length == 0) {
            writeJson(res, "{ \"error\": \"expected /v1/unix/users/<username>\" }", HTTPStatus.badRequest);
            return;
        }

        auto maybe = getUserUseCase.execute(username);
        if (!maybe.found) {
            writeJson(res, "{ \"error\": \"user not found\" }", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toView(maybe.value)), HTTPStatus.ok);
    }

    void createUser(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto command = toCreateUserCommand(payload);
            auto created = createUserUseCase.execute(command);
            writeJson(res, serializeToJsonString(toView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void userAction(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractRest(req.requestPath.to!string, "/v1/unix/users/");
        auto parts = rest.split("/");

        if (parts.length == 2 && parts[1] == "password") {
            try {
                auto payload = parseJsonString(req.bodyReader.readAllUTF8());
                auto command = SetPasswordCommand(
                    parts[0],
                    requiredString(payload, "password"),
                    optionalString(payload, "algorithm", "sha512")
                );

                auto updated = setPasswordUseCase.execute(command);
                writeJson(res, serializeToJsonString(toView(updated)), HTTPStatus.ok);
                return;
            } catch (Exception ex) {
                writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
                return;
            }
        }

        writeJson(res, "{ \"error\": \"unsupported user action\" }", HTTPStatus.notFound);
    }

    void generateHash(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto result = generateHashUseCase.execute(
                GenerateHashCommand(
                    requiredString(payload, "password"),
                    optionalString(payload, "algorithm", "sha512"),
                    optionalString(payload, "salt", "")
                )
            );

            writeJson(res, serializeToJsonString(result), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void verifyPassword(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto valid = verifyPasswordUseCase.execute(
                VerifyPasswordCommand(
                    requiredString(payload, "password"),
                    requiredString(payload, "existingHash")
                )
            );

            Json response = Json.emptyObject;
            response["valid"] = Json(valid);
            writeJson(res, serializeToJsonString(response), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    private CreateUserCommand toCreateUserCommand(Json j) {
        return CreateUserCommand(
            requiredString(j, "username"),
            requiredUInt(j, "uid"),
            requiredUInt(j, "gid"),
            optionalString(j, "gecos", ""),
            requiredString(j, "homeDirectory"),
            requiredString(j, "loginShell"),
            requiredString(j, "password")
        );
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

    private string optionalString(Json j, string key, string fallback) {
        if (!(key in j)) {
            return fallback;
        }
        return j[key].get!string;
    }

    private uint requiredUInt(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        return j[key].get!uint;
    }

    private UnixUserView toView(in UnixUser user) {
        return UnixUserView(
            user.passwd.username,
            user.passwd.uid,
            user.passwd.gid,
            user.passwd.gecos,
            user.passwd.homeDirectory,
            user.passwd.loginShell,
            user.hasShadow,
            user.hasShadow ? user.shadow.locked() : false,
            user.hasShadow ? user.shadow.passwordHash : "",
            user.hasShadow ? user.shadow.lastChangeDay : -1
        );
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

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
