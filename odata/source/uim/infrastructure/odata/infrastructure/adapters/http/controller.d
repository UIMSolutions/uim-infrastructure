module uim.infrastructure.odata.infrastructure.adapters.http.controller;

import std.conv : to;
import std.string : indexOf;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.status : HTTPStatus;
import vibe.data.json : Json;

import uim.infrastructure.odata.application.usecases.create_entity_type : CreateEntityTypeUseCase;
import uim.infrastructure.odata.application.usecases.list_entity_types : ListEntityTypesUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity_type : DeleteEntityTypeUseCase;
import uim.infrastructure.odata.application.usecases.create_entity_set : CreateEntitySetUseCase;
import uim.infrastructure.odata.application.usecases.list_entity_sets : ListEntitySetsUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity_set : DeleteEntitySetUseCase;
import uim.infrastructure.odata.application.usecases.create_entity : CreateEntityUseCase;
import uim.infrastructure.odata.application.usecases.get_entity : GetEntityUseCase;
import uim.infrastructure.odata.application.usecases.query_entities : QueryEntitiesUseCase;
import uim.infrastructure.odata.application.usecases.update_entity : UpdateEntityUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity : DeleteEntityUseCase;
import uim.infrastructure.odata.application.usecases.get_service_document : GetServiceDocumentUseCase;
import uim.infrastructure.odata.application.usecases.create_function_import : CreateFunctionImportUseCase;
import uim.infrastructure.odata.application.usecases.list_function_imports : ListFunctionImportsUseCase;

import uim.infrastructure.odata.application.dtos.entity_type;
import uim.infrastructure.odata.application.dtos.entity_set;
import uim.infrastructure.odata.application.dtos.entity;
import uim.infrastructure.odata.application.dtos.function_import;
import uim.infrastructure.odata.application.dtos.service_document;

import uim.infrastructure.odata.domain.entities.query_options : QueryOptions;

class ODataController {
    private CreateEntityTypeUseCase createEntityTypeUC;
    private ListEntityTypesUseCase listEntityTypesUC;
    private DeleteEntityTypeUseCase deleteEntityTypeUC;
    private CreateEntitySetUseCase createEntitySetUC;
    private ListEntitySetsUseCase listEntitySetsUC;
    private DeleteEntitySetUseCase deleteEntitySetUC;
    private CreateEntityUseCase createEntityUC;
    private GetEntityUseCase getEntityUC;
    private QueryEntitiesUseCase queryEntitiesUC;
    private UpdateEntityUseCase updateEntityUC;
    private DeleteEntityUseCase deleteEntityUC;
    private GetServiceDocumentUseCase getServiceDocUC;
    private CreateFunctionImportUseCase createFuncImportUC;
    private ListFunctionImportsUseCase listFuncImportsUC;

    this(
        CreateEntityTypeUseCase createEntityTypeUC,
        ListEntityTypesUseCase listEntityTypesUC,
        DeleteEntityTypeUseCase deleteEntityTypeUC,
        CreateEntitySetUseCase createEntitySetUC,
        ListEntitySetsUseCase listEntitySetsUC,
        DeleteEntitySetUseCase deleteEntitySetUC,
        CreateEntityUseCase createEntityUC,
        GetEntityUseCase getEntityUC,
        QueryEntitiesUseCase queryEntitiesUC,
        UpdateEntityUseCase updateEntityUC,
        DeleteEntityUseCase deleteEntityUC,
        GetServiceDocumentUseCase getServiceDocUC,
        CreateFunctionImportUseCase createFuncImportUC,
        ListFunctionImportsUseCase listFuncImportsUC,
    ) {
        this.createEntityTypeUC = createEntityTypeUC;
        this.listEntityTypesUC = listEntityTypesUC;
        this.deleteEntityTypeUC = deleteEntityTypeUC;
        this.createEntitySetUC = createEntitySetUC;
        this.listEntitySetsUC = listEntitySetsUC;
        this.deleteEntitySetUC = deleteEntitySetUC;
        this.createEntityUC = createEntityUC;
        this.getEntityUC = getEntityUC;
        this.queryEntitiesUC = queryEntitiesUC;
        this.updateEntityUC = updateEntityUC;
        this.deleteEntityUC = deleteEntityUC;
        this.getServiceDocUC = getServiceDocUC;
        this.createFuncImportUC = createFuncImportUC;
        this.listFuncImportsUC = listFuncImportsUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &healthCheck);

        // OData Service Document
        router.get("/odata/", &getServiceDocument);
        router.get("/odata", &getServiceDocument);

        // Metadata (EntityTypes)
        router.post("/odata/$metadata/entity-types", &createEntityType);
        router.get("/odata/$metadata/entity-types", &listEntityTypes);
        router.delete_("/odata/$metadata/entity-types/*", &deleteEntityType);

        // EntitySets
        router.post("/odata/$metadata/entity-sets", &createEntitySet);
        router.get("/odata/$metadata/entity-sets", &listEntitySets);
        router.delete_("/odata/$metadata/entity-sets/*", &deleteEntitySet);

        // Function/Action Imports
        router.post("/odata/$metadata/function-imports", &createFunctionImport);
        router.get("/odata/$metadata/function-imports", &listFunctionImports);

        // Entity CRUD via OData-style URLs
        router.post("/odata/*", &createEntity);
        router.get("/odata/*", &queryOrGetEntity);
        router.patch("/odata/*", &updateEntity);
        router.delete_("/odata/*", &deleteEntity);
    }

    // --- Health ---

    void healthCheck(HTTPServerRequest req, HTTPServerResponse res) {
        auto j = Json.emptyObject;
        j["status"] = "healthy";
        j["service"] = "uim-odata-service";
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Service Document ---

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        auto result = getServiceDocUC.execute();
        auto j = Json.emptyObject;
        j["@odata.context"] = result.context;
        auto arr = Json.emptyArray;
        foreach (ep; result.value) {
            auto e = Json.emptyObject;
            e["name"] = ep.name;
            e["kind"] = ep.kind;
            e["url"] = ep.url;
            arr ~= e;
        }
        j["value"] = arr;
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json;odata.metadata=minimal");
    }

    // --- EntityTypes ---

    void createEntityType(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            PropertyDTO[] props;
            if (j["properties"].type == Json.Type.array) {
                foreach (p; j["properties"]) {
                    props ~= PropertyDTO(
                        p["name"].get!string,
                        p["type"].type != Json.Type.undefined ? p["type"].get!string : "Edm.String",
                        p["nullable"].type != Json.Type.undefined ? p["nullable"].get!bool : true,
                        p["defaultValue"].type != Json.Type.undefined ? p["defaultValue"].get!string : "",
                        p["maxLength"].type != Json.Type.undefined ? p["maxLength"].get!uint : 0,
                    );
                }
            }

            NavigationPropertyDTO[] navProps;
            if (j["navigationProperties"].type == Json.Type.array) {
                foreach (np; j["navigationProperties"]) {
                    navProps ~= NavigationPropertyDTO(
                        np["name"].get!string,
                        np["targetEntityType"].get!string,
                        np["multiplicity"].type != Json.Type.undefined ? np["multiplicity"].get!string : "one",
                        np["partner"].type != Json.Type.undefined ? np["partner"].get!string : "",
                    );
                }
            }

            string[] keys;
            if (j["keyProperties"].type == Json.Type.array) {
                foreach (k; j["keyProperties"]) {
                    keys ~= k.get!string;
                }
            }

            auto dto = CreateEntityTypeDTO(
                j["name"].get!string,
                j["namespace"].type != Json.Type.undefined ? j["namespace"].get!string : "",
                keys,
                props,
                navProps,
            );

            auto result = createEntityTypeUC.execute(dto);
            res.writeBody(entityTypeToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listEntityTypes(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listEntityTypesUC.execute();
        auto arr = Json.emptyArray;
        foreach (et; results) arr ~= entityTypeToJson(et);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteEntityType(HTTPServerRequest req, HTTPServerResponse res) {
        auto name = extractLastSegment(req.requestURI);
        if (deleteEntityTypeUC.execute(name)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"EntityType not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- EntitySets ---

    void createEntitySet(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto dto = CreateEntitySetDTO(
                j["name"].get!string,
                j["entityTypeName"].get!string,
            );
            auto result = createEntitySetUC.execute(dto);
            auto rj = Json.emptyObject;
            rj["name"] = result.name;
            rj["entityTypeName"] = result.entityTypeName;
            res.writeBody(rj.toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listEntitySets(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listEntitySetsUC.execute();
        auto arr = Json.emptyArray;
        foreach (es; results) {
            auto j = Json.emptyObject;
            j["name"] = es.name;
            j["entityTypeName"] = es.entityTypeName;
            arr ~= j;
        }
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteEntitySet(HTTPServerRequest req, HTTPServerResponse res) {
        auto name = extractLastSegment(req.requestURI);
        if (deleteEntitySetUC.execute(name)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"EntitySet not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Function Imports ---

    void createFunctionImport(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            ParameterDTO[] params;
            if (j["parameters"].type == Json.Type.array) {
                foreach (p; j["parameters"]) {
                    params ~= ParameterDTO(
                        p["name"].get!string,
                        p["type"].type != Json.Type.undefined ? p["type"].get!string : "Edm.String",
                        p["nullable"].type != Json.Type.undefined ? p["nullable"].get!bool : true,
                    );
                }
            }

            auto dto = CreateFunctionImportDTO(
                j["name"].get!string,
                j["operationType"].type != Json.Type.undefined ? j["operationType"].get!string : "function",
                j["returnType"].type != Json.Type.undefined ? j["returnType"].get!string : "",
                j["isBound"].type != Json.Type.undefined ? j["isBound"].get!bool : false,
                j["boundToType"].type != Json.Type.undefined ? j["boundToType"].get!string : "",
                params,
            );

            auto result = createFuncImportUC.execute(dto);
            auto rj = Json.emptyObject;
            rj["name"] = result.name;
            rj["operationType"] = result.operationType;
            rj["returnType"] = result.returnType;
            rj["isBound"] = result.isBound;
            res.writeBody(rj.toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listFunctionImports(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listFuncImportsUC.execute();
        auto arr = Json.emptyArray;
        foreach (fi; results) {
            auto j = Json.emptyObject;
            j["name"] = fi.name;
            j["operationType"] = fi.operationType;
            j["returnType"] = fi.returnType;
            j["isBound"] = fi.isBound;
            arr ~= j;
        }
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Entity CRUD ---

    void createEntity(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            auto entitySetName = extractEntitySetName(req.requestURI);

            string[string] props;
            if (j.type == Json.Type.object) {
                foreach (string key, val; j) {
                    if (key.length > 0 && key[0] != '@') {
                        props[key] = val.type == Json.Type.string ? val.get!string : val.toString();
                    }
                }
            }

            auto dto = CreateEntityDTO(entitySetName, props);
            auto result = createEntityUC.execute(dto);

            auto rj = entityToODataJson(result, entitySetName);
            res.writeBody(rj.toString(), cast(int) HTTPStatus.created, "application/json;odata.metadata=minimal");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void queryOrGetEntity(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto entitySetName = extractEntitySetName(path);
        auto entityId = extractEntityId(path);

        if (entityId.length > 0) {
            // GET /odata/People('id')
            auto result = getEntityUC.execute(entitySetName, entityId);
            if (result is null) {
                res.writeBody(`{"error":"Entity not found"}`, cast(int) HTTPStatus.notFound, "application/json");
                return;
            }
            auto j = entityToODataJson(*result, entitySetName);
            j["@odata.context"] = "$metadata#" ~ entitySetName ~ "/$entity";
            res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json;odata.metadata=minimal");
        } else {
            // GET /odata/People?$filter=...&$top=...
            auto options = parseQueryOptions(req);
            auto result = queryEntitiesUC.execute(entitySetName, options);

            auto j = Json.emptyObject;
            j["@odata.context"] = result.context;
            if (result.hasCount) {
                j["@odata.count"] = result.count;
            }
            auto arr = Json.emptyArray;
            foreach (e; result.value) {
                arr ~= entityToODataJson(e, entitySetName);
            }
            j["value"] = arr;
            res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json;odata.metadata=minimal");
        }
    }

    void updateEntity(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            auto path = req.requestURI;
            auto entitySetName = extractEntitySetName(path);
            auto entityId = extractEntityId(path);

            string[string] props;
            if (j.type == Json.Type.object) {
                foreach (string key, val; j) {
                    if (key.length > 0 && key[0] != '@') {
                        props[key] = val.type == Json.Type.string ? val.get!string : val.toString();
                    }
                }
            }

            auto dto = UpdateEntityDTO(props);
            if (updateEntityUC.execute(entitySetName, entityId, dto)) {
                res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
            } else {
                res.writeBody(`{"error":"Entity not found"}`, cast(int) HTTPStatus.notFound, "application/json");
            }
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void deleteEntity(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto entitySetName = extractEntitySetName(path);
        auto entityId = extractEntityId(path);

        if (deleteEntityUC.execute(entitySetName, entityId)) {
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } else {
            res.writeBody(`{"error":"Entity not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Helpers ---

    private Json entityTypeToJson(in EntityTypeResponseDTO et) {
        auto j = Json.emptyObject;
        j["name"] = et.name;
        j["namespace"] = et.namespace_;
        j["fullName"] = et.fullName;
        auto kArr = Json.emptyArray;
        foreach (k; et.keyProperties) kArr ~= Json(k);
        j["keyProperties"] = kArr;
        auto pArr = Json.emptyArray;
        foreach (p; et.properties) {
            auto pj = Json.emptyObject;
            pj["name"] = p.name;
            pj["type"] = p.type;
            pj["nullable"] = p.nullable;
            pArr ~= pj;
        }
        j["properties"] = pArr;
        auto npArr = Json.emptyArray;
        foreach (np; et.navigationProperties) {
            auto npj = Json.emptyObject;
            npj["name"] = np.name;
            npj["targetEntityType"] = np.targetEntityType;
            npj["multiplicity"] = np.multiplicity;
            npArr ~= npj;
        }
        j["navigationProperties"] = npArr;
        return j;
    }

    private Json entityToODataJson(in EntityResponseDTO e, string entitySetName) {
        auto j = Json.emptyObject;
        j["@odata.id"] = entitySetName ~ "('" ~ e.id ~ "')";
        j["@odata.editLink"] = entitySetName ~ "('" ~ e.id ~ "')";
        foreach (k, v; e.properties) {
            j[k] = v;
        }
        return j;
    }

    private QueryOptions parseQueryOptions(HTTPServerRequest req) {
        QueryOptions opts;
        try {
            auto qp = req.queryParams();
            foreach (p; qp) {
                if (p[0] == "$filter") opts.filter = p[1];
                else if (p[0] == "$orderby") opts.orderby = p[1];
                else if (p[0] == "$top") { opts.top = p[1].to!uint; opts.hasTop = true; }
                else if (p[0] == "$skip") { opts.skip = p[1].to!uint; opts.hasSkip = true; }
                else if (p[0] == "$count") opts.count = (p[1] == "true");
                else if (p[0] == "$select") opts.select = p[1];
                else if (p[0] == "$expand") opts.expand = p[1];
                else if (p[0] == "$search") opts.search = p[1];
            }
        } catch (Exception e) {
            // use defaults
        }
        return opts;
    }

    // Extract entity set name from /odata/People('id') or /odata/People
    private string extractEntitySetName(string path) {
        // Remove query string
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];

        // Remove /odata/ prefix
        auto prefix = "/odata/";
        if (path.length > prefix.length && path[0 .. prefix.length] == prefix) {
            path = path[prefix.length .. $];
        }

        // Get up to '(' or end
        auto parenIdx = path.indexOf('(');
        if (parenIdx >= 0) return path[0 .. parenIdx];

        // Remove trailing slash
        if (path.length > 0 && path[$ - 1] == '/') path = path[0 .. $ - 1];
        return path;
    }

    // Extract entity ID from /odata/People('russellwhyte')
    private string extractEntityId(string path) {
        // Remove query string
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];

        auto openParen = path.indexOf('(');
        if (openParen < 0) return "";
        auto closeParen = path.indexOf(')');
        if (closeParen < 0) return "";

        auto idStr = path[openParen + 1 .. closeParen];
        // Remove surrounding quotes
        if (idStr.length >= 2 && idStr[0] == '\'') {
            idStr = idStr[1 .. $ - 1];
        }
        return idStr;
    }

    private string extractLastSegment(string path) {
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];
        if (path.length > 0 && path[$ - 1] == '/') path = path[0 .. $ - 1];
        for (long i = cast(long) path.length - 1; i >= 0; i--) {
            if (path[cast(size_t) i] == '/') return path[cast(size_t)(i + 1) .. $];
        }
        return path;
    }
}
