/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.infrastructure.http.controllers.scim;

import std.conv : to;
import std.exception : collectException;
import std.string : indexOf, split, startsWith, strip, toLower;
import uim.infrastructure.scim.application.dto.scim_commands :
    CreateGroupCommand,
    CreateUserCommand,
    ReplaceGroupCommand,
    ReplaceUserCommand;
import uim.infrastructure.scim.application.usecases.create_group : CreateGroupUseCase;
import uim.infrastructure.scim.application.usecases.create_user : CreateUserUseCase;
import uim.infrastructure.scim.application.usecases.delete_group : DeleteGroupUseCase;
import uim.infrastructure.scim.application.usecases.delete_user : DeleteUserUseCase;
import uim.infrastructure.scim.application.usecases.get_group : GetGroupUseCase;
import uim.infrastructure.scim.application.usecases.get_user : GetUserUseCase;
import uim.infrastructure.scim.application.usecases.list_groups : ListGroupsUseCase;
import uim.infrastructure.scim.application.usecases.list_users : ListUsersUseCase;
import uim.infrastructure.scim.application.usecases.replace_group : ReplaceGroupUseCase;
import uim.infrastructure.scim.application.usecases.replace_user : ReplaceUserUseCase;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.infrastructure.auth.token_validator : ITokenValidator, TokenContext;
import vibe.data.json : Json;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class ScimController {
    private enum string scimContentType = "application/scim+json";

    private ListUsersUseCase listUsersUseCase;
    private CreateUserUseCase createUserUseCase;
    private GetUserUseCase getUserUseCase;
    private ReplaceUserUseCase replaceUserUseCase;
    private DeleteUserUseCase deleteUserUseCase;

    private ListGroupsUseCase listGroupsUseCase;
    private CreateGroupUseCase createGroupUseCase;
    private GetGroupUseCase getGroupUseCase;
    private ReplaceGroupUseCase replaceGroupUseCase;
    private DeleteGroupUseCase deleteGroupUseCase;

    private string baseUrl;
    private ITokenValidator tokenValidator;
    private bool allowAnonymousDiscovery;

    this(
        ListUsersUseCase listUsersUseCase,
        CreateUserUseCase createUserUseCase,
        GetUserUseCase getUserUseCase,
        ReplaceUserUseCase replaceUserUseCase,
        DeleteUserUseCase deleteUserUseCase,
        ListGroupsUseCase listGroupsUseCase,
        CreateGroupUseCase createGroupUseCase,
        GetGroupUseCase getGroupUseCase,
        ReplaceGroupUseCase replaceGroupUseCase,
        DeleteGroupUseCase deleteGroupUseCase,
        string baseUrl,
        ITokenValidator tokenValidator,
        bool allowAnonymousDiscovery
    ) {
        this.listUsersUseCase = listUsersUseCase;
        this.createUserUseCase = createUserUseCase;
        this.getUserUseCase = getUserUseCase;
        this.replaceUserUseCase = replaceUserUseCase;
        this.deleteUserUseCase = deleteUserUseCase;
        this.listGroupsUseCase = listGroupsUseCase;
        this.createGroupUseCase = createGroupUseCase;
        this.getGroupUseCase = getGroupUseCase;
        this.replaceGroupUseCase = replaceGroupUseCase;
        this.deleteGroupUseCase = deleteGroupUseCase;
        this.baseUrl = baseUrl;
        this.tokenValidator = tokenValidator;
        this.allowAnonymousDiscovery = allowAnonymousDiscovery;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        router.get("/scim/v2/ServiceProviderConfig", &serviceProviderConfig);
        router.get("/scim/v2/ResourceTypes", &resourceTypes);
        router.get("/scim/v2/Schemas", &schemas);

        router.get("/scim/v2/Users", &listUsers);
        router.post("/scim/v2/Users", &createUser);
        router.get("/scim/v2/Users/*", &getUser);
        router.put("/scim/v2/Users/*", &replaceUser);
        router.patch("/scim/v2/Users/*", &patchUser);
        router.delete_("/scim/v2/Users/*", &deleteUser);

        router.get("/scim/v2/Groups", &listGroups);
        router.post("/scim/v2/Groups", &createGroup);
        router.get("/scim/v2/Groups/*", &getGroup);
        router.put("/scim/v2/Groups/*", &replaceGroup);
        router.patch("/scim/v2/Groups/*", &patchGroup);
        router.delete_("/scim/v2/Groups/*", &deleteGroup);

        router.post("/scim/v2/Bulk", &bulk);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = Json.emptyObject;
        body["status"] = Json("ok");
        writeJson(res, body, HTTPStatus.ok, "application/json");
    }

    void serviceProviderConfig(HTTPServerRequest req, HTTPServerResponse res) {
        if (!allowAnonymousDiscovery) {
            auto auth = authenticate(req, res);
            if (auth is null) {
                return;
            }
        }

        auto body = Json.emptyObject;
        body["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:ServiceProviderConfig"]);
        body["patch"] = capability(true);
        body["bulk"] = capability(true, 1000);
        body["filter"] = capability(true, 200);
        body["changePassword"] = capability(false);
        body["sort"] = capability(true);
        body["etag"] = capability(true);
        body["authenticationSchemes"] = toJsonArray([
            bearerAuthScheme()
        ]);

        writeJson(res, body, HTTPStatus.ok, scimContentType);
    }

    void resourceTypes(HTTPServerRequest req, HTTPServerResponse res) {
        if (!allowAnonymousDiscovery) {
            auto auth = authenticate(req, res);
            if (auth is null) {
                return;
            }
        }

        auto body = listResponse([
            resourceTypeJson("User", "/Users", "urn:ietf:params:scim:schemas:core:2.0:User"),
            resourceTypeJson("Group", "/Groups", "urn:ietf:params:scim:schemas:core:2.0:Group")
        ], 1, 2, 2);

        writeJson(res, body, HTTPStatus.ok, scimContentType);
    }

    void schemas(HTTPServerRequest req, HTTPServerResponse res) {
        if (!allowAnonymousDiscovery) {
            auto auth = authenticate(req, res);
            if (auth is null) {
                return;
            }
        }

        auto body = listResponse([
            schemaUserJson(),
            schemaGroupJson()
        ], 1, 2, 2);

        writeJson(res, body, HTTPStatus.ok, scimContentType);
    }

    void listUsers(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        string filterAttr;
        string filterValue;
        parseFilter(readQuery(req, "filter"), filterAttr, filterValue);

        auto users = listUsersUseCase.execute(filterAttr, filterValue);

        auto startIndex = readPositiveIntQuery(req, "startIndex", 1);
        auto count = readPositiveIntQuery(req, "count", cast(int) users.length);

        auto paged = paginate(users, startIndex, count);
        Json[] resources;
        foreach (user; paged) {
            resources ~= userToJson(user);
        }

        auto body = listResponse(resources, startIndex, count, cast(int) users.length);
        writeJson(res, body, HTTPStatus.ok, scimContentType);
    }

    void createUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        try {
            auto json = requireJson(req);
            auto command = CreateUserCommand(
                optionalString(json, "externalId"),
                requiredString(json, "userName"),
                optionalString(json, "displayName"),
                optionalString(json["name"], "givenName"),
                optionalString(json["name"], "familyName"),
                parseEmails(json)
            );

            auto created = createUserUseCase.execute(command);
            setResourceHeaders(res, userLocation(created.id), created.versionTag);
            writeJson(res, userToJson(created), HTTPStatus.created, scimContentType);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void getUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Users/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Users/<id>");
            return;
        }

        auto user = getUserUseCase.execute(id);
        if (user is null) {
            writeError(res, HTTPStatus.notFound, "user not found");
            return;
        }

        setResourceHeaders(res, userLocation(id), user.versionTag);
        writeJson(res, userToJson(*user), HTTPStatus.ok, scimContentType);
    }

    void replaceUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Users/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Users/<id>");
            return;
        }

        try {
            auto json = requireJson(req);
            auto command = ReplaceUserCommand(
                optionalString(json, "externalId"),
                requiredString(json, "userName"),
                optionalString(json, "displayName"),
                optionalString(json["name"], "givenName"),
                optionalString(json["name"], "familyName"),
                parseEmails(json)
            );

            auto updated = replaceUserUseCase.execute(id, command);
            setResourceHeaders(res, userLocation(id), updated.versionTag);
            writeJson(res, userToJson(updated), HTTPStatus.ok, scimContentType);
        } catch (Exception ex) {
            auto status = ex.msg == "user not found" ? HTTPStatus.notFound : HTTPStatus.badRequest;
            writeError(res, status, ex.msg);
        }
    }

    void deleteUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Users/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Users/<id>");
            return;
        }

        if (getUserUseCase.execute(id) is null) {
            writeError(res, HTTPStatus.notFound, "user not found");
            return;
        }

        deleteUserUseCase.execute(id);
        res.writeBody("", cast(int) HTTPStatus.noContent, scimContentType);
    }

    void listGroups(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        string filterAttr;
        string filterValue;
        parseFilter(readQuery(req, "filter"), filterAttr, filterValue);

        auto groups = listGroupsUseCase.execute(filterAttr, filterValue);

        auto startIndex = readPositiveIntQuery(req, "startIndex", 1);
        auto count = readPositiveIntQuery(req, "count", cast(int) groups.length);

        auto paged = paginate(groups, startIndex, count);
        Json[] resources;
        foreach (group; paged) {
            resources ~= groupToJson(group);
        }

        auto body = listResponse(resources, startIndex, count, cast(int) groups.length);
        writeJson(res, body, HTTPStatus.ok, scimContentType);
    }

    void createGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        try {
            auto json = requireJson(req);
            auto command = CreateGroupCommand(
                optionalString(json, "externalId"),
                requiredString(json, "displayName"),
                parseMembers(json)
            );

            auto created = createGroupUseCase.execute(command);
            setResourceHeaders(res, groupLocation(created.id), created.versionTag);
            writeJson(res, groupToJson(created), HTTPStatus.created, scimContentType);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void getGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Groups/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Groups/<id>");
            return;
        }

        auto group = getGroupUseCase.execute(id);
        if (group is null) {
            writeError(res, HTTPStatus.notFound, "group not found");
            return;
        }

        setResourceHeaders(res, groupLocation(id), group.versionTag);
        writeJson(res, groupToJson(*group), HTTPStatus.ok, scimContentType);
    }

    void replaceGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Groups/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Groups/<id>");
            return;
        }

        try {
            auto json = requireJson(req);
            auto command = ReplaceGroupCommand(
                optionalString(json, "externalId"),
                requiredString(json, "displayName"),
                parseMembers(json)
            );

            auto updated = replaceGroupUseCase.execute(id, command);
            setResourceHeaders(res, groupLocation(id), updated.versionTag);
            writeJson(res, groupToJson(updated), HTTPStatus.ok, scimContentType);
        } catch (Exception ex) {
            auto status = ex.msg == "group not found" ? HTTPStatus.notFound : HTTPStatus.badRequest;
            writeError(res, status, ex.msg);
        }
    }

    void deleteGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Groups/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Groups/<id>");
            return;
        }

        if (getGroupUseCase.execute(id) is null) {
            writeError(res, HTTPStatus.notFound, "group not found");
            return;
        }

        deleteGroupUseCase.execute(id);
        res.writeBody("", cast(int) HTTPStatus.noContent, scimContentType);
    }

    void patchUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Users/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Users/<id>");
            return;
        }

        auto existing = getUserUseCase.execute(id);
        if (existing is null) {
            writeError(res, HTTPStatus.notFound, "user not found");
            return;
        }

        try {
            auto body = requireJson(req);
            auto command = ReplaceUserCommand(
                existing.externalId,
                existing.userName,
                existing.displayName,
                existing.givenName,
                existing.familyName,
                existing.emails.dup
            );

            applyUserPatch(command, body);
            auto updated = replaceUserUseCase.execute(id, command);
            setResourceHeaders(res, userLocation(id), updated.versionTag);
            writeJson(res, userToJson(updated), HTTPStatus.ok, scimContentType);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void patchGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/scim/v2/Groups/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /scim/v2/Groups/<id>");
            return;
        }

        auto existing = getGroupUseCase.execute(id);
        if (existing is null) {
            writeError(res, HTTPStatus.notFound, "group not found");
            return;
        }

        try {
            auto body = requireJson(req);
            auto command = ReplaceGroupCommand(
                existing.externalId,
                existing.displayName,
                existing.memberIds.dup
            );

            applyGroupPatch(command, body);
            auto updated = replaceGroupUseCase.execute(id, command);
            setResourceHeaders(res, groupLocation(id), updated.versionTag);
            writeJson(res, groupToJson(updated), HTTPStatus.ok, scimContentType);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void bulk(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }
        if (!auth.isAdmin()) {
            writeError(res, HTTPStatus.forbidden, "bulk requires admin role");
            return;
        }

        try {
            auto body = requireJson(req);
            auto failOnErrors = readPositiveInt(body, "failOnErrors", 0);
            auto operations = body["Operations"];
            if (operations.type != Json.Type.array) {
                throw new Exception("Operations array is required");
            }

            auto responses = Json.emptyArray;
            int errorCount = 0;

            foreach (operation; operations) {
                auto result = executeBulkOperation(operation);
                responses.appendArrayElement(result);
                if (result["status"].type == Json.Type.string) {
                    auto statusCode = to!int(result["status"].get!string);
                    if (statusCode >= 400) {
                        errorCount++;
                    }
                }

                if (failOnErrors > 0 && errorCount >= failOnErrors) {
                    break;
                }
            }

            auto payload = Json.emptyObject;
            payload["schemas"] = toJsonArray(["urn:ietf:params:scim:api:messages:2.0:BulkResponse"]);
            payload["Operations"] = responses;
            writeJson(res, payload, HTTPStatus.ok, scimContentType);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    private void applyUserPatch(ref ReplaceUserCommand command, Json body) {
        auto operations = body["Operations"];
        if (operations.type != Json.Type.array) {
            throw new Exception("PATCH Operations array is required");
        }

        foreach (op; operations) {
            auto operation = toLower(optionalString(op, "op"));
            auto path = toLower(optionalString(op, "path"));
            auto value = op["value"];

            if (operation == "remove") {
                applyUserRemove(command, path);
                continue;
            }

            if (path.length == 0 && value.type == Json.Type.object) {
                command.externalId = optionalString(value, "externalId");
                if (value["userName"].type == Json.Type.string) {
                    command.userName = value["userName"].get!string;
                }
                if (value["displayName"].type == Json.Type.string) {
                    command.displayName = value["displayName"].get!string;
                }
                if (value["name"].type == Json.Type.object) {
                    command.givenName = optionalString(value["name"], "givenName");
                    command.familyName = optionalString(value["name"], "familyName");
                }
                if (value["emails"].type == Json.Type.array) {
                    command.emails = parseEmails(value);
                }
                continue;
            }

            if (path == "externalid") {
                command.externalId = readPatchString(value, "externalId");
            } else if (path == "username") {
                command.userName = readPatchString(value, "userName");
            } else if (path == "displayname") {
                command.displayName = readPatchString(value, "displayName");
            } else if (path == "name.givenname") {
                command.givenName = readPatchString(value, "name.givenName");
            } else if (path == "name.familyname") {
                command.familyName = readPatchString(value, "name.familyName");
            } else if (path == "emails") {
                if (value.type == Json.Type.array) {
                    auto emailBody = Json.emptyObject;
                    emailBody["emails"] = value;
                    command.emails = parseEmails(emailBody);
                }
            }
        }
    }

    private void applyUserRemove(ref ReplaceUserCommand command, string path) {
        if (path == "externalid") {
            command.externalId = "";
        } else if (path == "displayname") {
            command.displayName = "";
        } else if (path == "name.givenname") {
            command.givenName = "";
        } else if (path == "name.familyname") {
            command.familyName = "";
        } else if (path == "emails") {
            command.emails = [];
        }
    }

    private void applyGroupPatch(ref ReplaceGroupCommand command, Json body) {
        auto operations = body["Operations"];
        if (operations.type != Json.Type.array) {
            throw new Exception("PATCH Operations array is required");
        }

        foreach (op; operations) {
            auto operation = toLower(optionalString(op, "op"));
            auto path = toLower(optionalString(op, "path"));
            auto value = op["value"];

            if (operation == "remove") {
                if (path == "externalid") {
                    command.externalId = "";
                } else if (path == "members") {
                    command.memberIds = [];
                }
                continue;
            }

            if (path.length == 0 && value.type == Json.Type.object) {
                command.externalId = optionalString(value, "externalId");
                if (value["displayName"].type == Json.Type.string) {
                    command.displayName = value["displayName"].get!string;
                }
                if (value["members"].type == Json.Type.array) {
                    command.memberIds = parseMembers(value);
                }
                continue;
            }

            if (path == "externalid") {
                command.externalId = readPatchString(value, "externalId");
            } else if (path == "displayname") {
                command.displayName = readPatchString(value, "displayName");
            } else if (path == "members") {
                if (value.type == Json.Type.array) {
                    auto memberBody = Json.emptyObject;
                    memberBody["members"] = value;
                    command.memberIds = parseMembers(memberBody);
                }
            }
        }
    }

    private string readPatchString(Json value, string name) {
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        throw new Exception(name ~ " must be string");
    }

    private Json executeBulkOperation(Json operation) {
        auto method = toLower(optionalString(operation, "method"));
        auto path = optionalString(operation, "path");
        auto bulkId = optionalString(operation, "bulkId");
        auto data = operation["data"];

        auto result = Json.emptyObject;
        result["method"] = Json(httpMethodLabel(method));
        if (bulkId.length > 0) {
            result["bulkId"] = Json(bulkId);
        }

        try {
            if (method == "post" && path == "/Users") {
                auto cmd = CreateUserCommand(
                    optionalString(data, "externalId"),
                    requiredString(data, "userName"),
                    optionalString(data, "displayName"),
                    optionalString(data["name"], "givenName"),
                    optionalString(data["name"], "familyName"),
                    parseEmails(data)
                );
                auto created = createUserUseCase.execute(cmd);
                result["status"] = Json("201");
                result["location"] = Json(userLocation(created.id));
                result["response"] = userToJson(created);
                return result;
            }

            if (method == "post" && path == "/Groups") {
                auto cmd = CreateGroupCommand(
                    optionalString(data, "externalId"),
                    requiredString(data, "displayName"),
                    parseMembers(data)
                );
                auto created = createGroupUseCase.execute(cmd);
                result["status"] = Json("201");
                result["location"] = Json(groupLocation(created.id));
                result["response"] = groupToJson(created);
                return result;
            }

            if (method == "delete" && startsWith(path, "/Users/")) {
                auto id = path[7 .. $];
                if (getUserUseCase.execute(id) is null) {
                    throw new Exception("user not found");
                }
                deleteUserUseCase.execute(id);
                result["status"] = Json("204");
                return result;
            }

            if (method == "delete" && startsWith(path, "/Groups/")) {
                auto id = path[8 .. $];
                if (getGroupUseCase.execute(id) is null) {
                    throw new Exception("group not found");
                }
                deleteGroupUseCase.execute(id);
                result["status"] = Json("204");
                return result;
            }

            if ((method == "put" || method == "patch") && startsWith(path, "/Users/")) {
                auto id = path[7 .. $];
                auto existing = getUserUseCase.execute(id);
                if (existing is null) {
                    throw new Exception("user not found");
                }

                auto cmd = ReplaceUserCommand(
                    existing.externalId,
                    existing.userName,
                    existing.displayName,
                    existing.givenName,
                    existing.familyName,
                    existing.emails.dup
                );

                if (method == "put") {
                    cmd = ReplaceUserCommand(
                        optionalString(data, "externalId"),
                        requiredString(data, "userName"),
                        optionalString(data, "displayName"),
                        optionalString(data["name"], "givenName"),
                        optionalString(data["name"], "familyName"),
                        parseEmails(data)
                    );
                } else {
                    auto patchBody = Json.emptyObject;
                    patchBody["Operations"] = data["Operations"];
                    applyUserPatch(cmd, patchBody);
                }

                auto updated = replaceUserUseCase.execute(id, cmd);
                result["status"] = Json("200");
                result["location"] = Json(userLocation(id));
                result["response"] = userToJson(updated);
                return result;
            }

            if ((method == "put" || method == "patch") && startsWith(path, "/Groups/")) {
                auto id = path[8 .. $];
                auto existing = getGroupUseCase.execute(id);
                if (existing is null) {
                    throw new Exception("group not found");
                }

                auto cmd = ReplaceGroupCommand(
                    existing.externalId,
                    existing.displayName,
                    existing.memberIds.dup
                );

                if (method == "put") {
                    cmd = ReplaceGroupCommand(
                        optionalString(data, "externalId"),
                        requiredString(data, "displayName"),
                        parseMembers(data)
                    );
                } else {
                    auto patchBody = Json.emptyObject;
                    patchBody["Operations"] = data["Operations"];
                    applyGroupPatch(cmd, patchBody);
                }

                auto updated = replaceGroupUseCase.execute(id, cmd);
                result["status"] = Json("200");
                result["location"] = Json(groupLocation(id));
                result["response"] = groupToJson(updated);
                return result;
            }

            throw new Exception("unsupported bulk operation");
        } catch (Exception ex) {
            result["status"] = Json("400");
            auto errorBody = Json.emptyObject;
            errorBody["schemas"] = toJsonArray(["urn:ietf:params:scim:api:messages:2.0:Error"]);
            errorBody["status"] = Json("400");
            errorBody["detail"] = Json(ex.msg);
            result["response"] = errorBody;
            return result;
        }
    }

    private TokenContext* authenticate(HTTPServerRequest req, HTTPServerResponse res) {
        auto header = req.headers.get("Authorization", "");
        if (!startsWith(toLower(header), "bearer ")) {
            writeError(res, HTTPStatus.unauthorized, "missing bearer token");
            return null;
        }

        auto token = header[7 .. $].strip();
        auto context = tokenValidator.validateToken(token);
        if (context is null) {
            writeError(res, HTTPStatus.unauthorized, "invalid token");
            return null;
        }

        return context;
    }

    private Json bearerAuthScheme() {
        auto scheme = Json.emptyObject;
        scheme["type"] = Json("oauthbearertoken");
        scheme["name"] = Json("Bearer Token");
        scheme["description"] = Json("Authorization: Bearer <token>");
        scheme["specUri"] = Json("https://datatracker.ietf.org/doc/html/rfc6750");
        scheme["primary"] = Json(true);
        return scheme;
    }

    private int readPositiveInt(Json json, string key, int fallback) {
        if (json[key].type == Json.Type.int_ || json[key].type == Json.Type.bigInt) {
            auto value = json[key].get!long;
            return value <= 0 ? fallback : cast(int) value;
        }
        return fallback;
    }

    private string httpMethodLabel(string method) {
        auto lowered = toLower(method);
        if (lowered == "post") {
            return "POST";
        }
        if (lowered == "put") {
            return "PUT";
        }
        if (lowered == "patch") {
            return "PATCH";
        }
        if (lowered == "delete") {
            return "DELETE";
        }
        if (lowered == "get") {
            return "GET";
        }
        return method;
    }

    private Json capability(bool supported, int maxResults = 0) {
        auto j = Json.emptyObject;
        j["supported"] = Json(supported);
        if (maxResults > 0) {
            j["maxResults"] = Json(maxResults);
        }
        return j;
    }

    private Json resourceTypeJson(string name, string endpoint, string schema) {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:ResourceType"]);
        j["id"] = Json(name);
        j["name"] = Json(name);
        j["endpoint"] = Json(endpoint);
        j["schema"] = Json(schema);
        return j;
    }

    private Json schemaUserJson() {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:Schema"]);
        j["id"] = Json("urn:ietf:params:scim:schemas:core:2.0:User");
        j["name"] = Json("User");
        j["description"] = Json("User Account");
        j["attributes"] = toJsonArray([
            attribute("userName", "string", true),
            attribute("displayName", "string", false),
            attribute("externalId", "string", false),
            attribute("emails", "complex", false),
            attribute("name", "complex", false)
        ]);
        return j;
    }

    private Json schemaGroupJson() {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:Schema"]);
        j["id"] = Json("urn:ietf:params:scim:schemas:core:2.0:Group");
        j["name"] = Json("Group");
        j["description"] = Json("Group");
        j["attributes"] = toJsonArray([
            attribute("displayName", "string", true),
            attribute("externalId", "string", false),
            attribute("members", "complex", false)
        ]);
        return j;
    }

    private Json attribute(string name, string type, bool required) {
        auto j = Json.emptyObject;
        j["name"] = Json(name);
        j["type"] = Json(type);
        j["required"] = Json(required);
        return j;
    }

    private Json userToJson(ScimUser user) {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:User"]);
        j["id"] = Json(user.id);
        if (user.externalId.length > 0) {
            j["externalId"] = Json(user.externalId);
        }
        j["userName"] = Json(user.userName);
        if (user.displayName.length > 0) {
            j["displayName"] = Json(user.displayName);
        }

        auto name = Json.emptyObject;
        if (user.givenName.length > 0) {
            name["givenName"] = Json(user.givenName);
        }
        if (user.familyName.length > 0) {
            name["familyName"] = Json(user.familyName);
        }
        if (name.type == Json.Type.object) {
            j["name"] = name;
        }

        auto emails = Json.emptyArray;
        foreach (email; user.emails) {
            if (email.length == 0) {
                continue;
            }
            auto item = Json.emptyObject;
            item["value"] = Json(email);
            item["type"] = Json("work");
            emails.appendArrayElement(item);
        }
        if (user.emails.length > 0) {
            j["emails"] = emails;
        }

        j["meta"] = metaJson(
            "User",
            userLocation(user.id),
            user.createdAt.toISOExtString(),
            user.lastModifiedAt.toISOExtString(),
            user.versionTag
        );
        return j;
    }

    private Json groupToJson(ScimGroup group) {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:schemas:core:2.0:Group"]);
        j["id"] = Json(group.id);
        if (group.externalId.length > 0) {
            j["externalId"] = Json(group.externalId);
        }
        j["displayName"] = Json(group.displayName);

        auto members = Json.emptyArray;
        foreach (memberId; group.memberIds) {
            if (memberId.length == 0) {
                continue;
            }
            auto item = Json.emptyObject;
            item["value"] = Json(memberId);
            item["$ref"] = Json(userLocation(memberId));
            members.appendArrayElement(item);
        }
        if (group.memberIds.length > 0) {
            j["members"] = members;
        }

        j["meta"] = metaJson(
            "Group",
            groupLocation(group.id),
            group.createdAt.toISOExtString(),
            group.lastModifiedAt.toISOExtString(),
            group.versionTag
        );
        return j;
    }

    private Json metaJson(
        string resourceType,
        string location,
        string created,
        string lastModified,
        string versionTag
    ) {
        auto meta = Json.emptyObject;
        meta["resourceType"] = Json(resourceType);
        meta["created"] = Json(created);
        meta["lastModified"] = Json(lastModified);
        meta["location"] = Json(location);
        meta["version"] = Json(versionTag);
        return meta;
    }

    private Json listResponse(Json[] resources, int startIndex, int count, int totalResults) {
        auto j = Json.emptyObject;
        j["schemas"] = toJsonArray(["urn:ietf:params:scim:api:messages:2.0:ListResponse"]);
        j["totalResults"] = Json(totalResults);
        j["startIndex"] = Json(startIndex);
        j["itemsPerPage"] = Json(count);

        auto arr = Json.emptyArray;
        foreach (resource; resources) {
            arr.appendArrayElement(resource);
        }
        j["Resources"] = arr;
        return j;
    }

    private Json toJsonArray(string[] values) {
        auto arr = Json.emptyArray;
        foreach (value; values) {
            arr.appendArrayElement(Json(value));
        }
        return arr;
    }

    private Json toJsonArray(Json[] values) {
        auto arr = Json.emptyArray;
        foreach (value; values) {
            arr.appendArrayElement(value);
        }
        return arr;
    }

    private Json requireJson(HTTPServerRequest req) {
        auto body = req.json;
        if (body.type == Json.Type.undefined || body.type != Json.Type.object) {
            throw new Exception("request body must be JSON object");
        }
        return body;
    }

    private string requiredString(Json json, string key) {
        if (json[key].type != Json.Type.string || json[key].get!string.length == 0) {
            throw new Exception(key ~ " is required");
        }
        return json[key].get!string;
    }

    private string optionalString(Json json, string key) {
        return json[key].type == Json.Type.string ? json[key].get!string : "";
    }

    private string[] parseEmails(Json json) {
        string[] emails;
        if (json["emails"].type == Json.Type.array) {
            foreach (entry; json["emails"]) {
                if (entry["value"].type == Json.Type.string) {
                    emails ~= entry["value"].get!string;
                }
            }
        }
        return emails;
    }

    private string[] parseMembers(Json json) {
        string[] memberIds;
        if (json["members"].type == Json.Type.array) {
            foreach (entry; json["members"]) {
                if (entry["value"].type == Json.Type.string) {
                    memberIds ~= entry["value"].get!string;
                }
            }
        }
        return memberIds;
    }

    private string userLocation(string id) {
        return baseUrl ~ "/Users/" ~ id;
    }

    private string groupLocation(string id) {
        return baseUrl ~ "/Groups/" ~ id;
    }

    private void setResourceHeaders(HTTPServerResponse res, string location, string etag) {
        res.headers["Location"] = location;
        res.headers["ETag"] = etag;
    }

    private void writeError(HTTPServerResponse res, HTTPStatus status, string detail) {
        auto errorPayload = Json.emptyObject;
        errorPayload["schemas"] = toJsonArray(["urn:ietf:params:scim:api:messages:2.0:Error"]);
        errorPayload["status"] = Json((cast(int) status).to!string);
        errorPayload["detail"] = Json(detail);
        writeJson(res, errorPayload, status, scimContentType);
    }

    private void writeJson(HTTPServerResponse res, Json body, HTTPStatus status, string contentType) {
        res.writeBody(body.toString(), cast(int) status, contentType);
    }

    private string readWildcardId(string path, string prefix) {
        if (!path.startsWith(prefix)) {
            return "";
        }

        auto segments = split(path[prefix.length .. $], "/");
        return segments.length == 0 ? "" : segments[0];
    }

    private string readQuery(HTTPServerRequest req, string key) {
        auto value = key in req.query;
        return value is null ? "" : *value;
    }

    private int readPositiveIntQuery(HTTPServerRequest req, string key, int fallback) {
        auto raw = readQuery(req, key);
        if (raw.length == 0) {
            return fallback <= 0 ? 1 : fallback;
        }

        int value;
        auto err = collectException(value = raw.to!int);
        if (err !is null || value <= 0) {
            return fallback <= 0 ? 1 : fallback;
        }

        return value;
    }

    private T[] paginate(T)(T[] all, int startIndex, int count) {
        if (all.length == 0) {
            return [];
        }

        auto start = startIndex - 1;
        if (start < 0) {
            start = 0;
        }
        if (start >= cast(int) all.length) {
            return [];
        }

        auto effectiveCount = count <= 0 ? cast(int) all.length : count;
        auto stop = start + effectiveCount;
        if (stop > cast(int) all.length) {
            stop = cast(int) all.length;
        }

        return all[start .. stop].dup;
    }

    private void parseFilter(string filter, out string attribute, out string value) {
        attribute = "";
        value = "";

        auto normalized = filter.strip();
        if (normalized.length == 0) {
            return;
        }

        auto lower = toLower(normalized);
        auto operatorIndex = lower.indexOf(" eq ");
        if (operatorIndex <= 0) {
            return;
        }

        attribute = normalized[0 .. operatorIndex].strip();
        value = normalized[operatorIndex + 4 .. $].strip();

        if (value.length >= 2) {
            if ((value[0] == '"' && value[$ - 1] == '"') || (value[0] == '\'' && value[$ - 1] == '\'')) {
                value = value[1 .. $ - 1];
            }
        }
    }
}
