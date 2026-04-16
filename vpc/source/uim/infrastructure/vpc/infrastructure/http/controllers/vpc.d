module vpc_service.infrastructure.http.controllers.vpc;

import vpc_service.application.dto.vpc_commands :
    CreateVpcCommand, DeleteVpcCommand,
    CreateSubnetCommand, DeleteSubnetCommand;
import vpc_service.application.usecases.create_vpc : CreateVpcUseCase;
import vpc_service.application.usecases.delete_vpc : DeleteVpcUseCase;
import vpc_service.application.usecases.get_vpc : GetVpcUseCase;
import vpc_service.application.usecases.list_vpcs : ListVpcsUseCase;
import vpc_service.application.usecases.create_subnet : CreateSubnetUseCase;
import vpc_service.application.usecases.delete_subnet : DeleteSubnetUseCase;
import vpc_service.application.usecases.list_subnets : ListSubnetsUseCase;
import vpc_service.domain.entities.vpc : Vpc;
import vpc_service.domain.entities.subnet : Subnet;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct VpcView {
    string id;
    string name;
    string cidr;
    string region;
    string state;
}

struct SubnetView {
    string id;
    string vpcId;
    string name;
    string cidr;
    string availabilityZone;
    string state;
}

class VpcController {
    private CreateVpcUseCase    createVpcUseCase;
    private DeleteVpcUseCase    deleteVpcUseCase;
    private ListVpcsUseCase     listVpcsUseCase;
    private GetVpcUseCase       getVpcUseCase;
    private CreateSubnetUseCase createSubnetUseCase;
    private DeleteSubnetUseCase deleteSubnetUseCase;
    private ListSubnetsUseCase  listSubnetsUseCase;

    this(
        CreateVpcUseCase    createVpcUseCase,
        DeleteVpcUseCase    deleteVpcUseCase,
        ListVpcsUseCase     listVpcsUseCase,
        GetVpcUseCase       getVpcUseCase,
        CreateSubnetUseCase createSubnetUseCase,
        DeleteSubnetUseCase deleteSubnetUseCase,
        ListSubnetsUseCase  listSubnetsUseCase
    ) {
        this.createVpcUseCase    = createVpcUseCase;
        this.deleteVpcUseCase    = deleteVpcUseCase;
        this.listVpcsUseCase     = listVpcsUseCase;
        this.getVpcUseCase       = getVpcUseCase;
        this.createSubnetUseCase = createSubnetUseCase;
        this.deleteSubnetUseCase = deleteSubnetUseCase;
        this.listSubnetsUseCase  = listSubnetsUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get    ("/health",                    &health);
        router.get    ("/v1/vpcs",                   &listVpcs);
        router.get    ("/v1/subnets",                &listAllSubnets);
        // More specific routes must be registered before the wildcard /v1/vpcs/*
        router.get    ("/v1/vpcs/*/subnets",         &listSubnets);
        router.post   ("/v1/vpcs/*/subnets/*",       &createSubnet);
        router.post   ("/v1/vpcs/*",                 &createVpc);
        router.delete_("/v1/vpcs/*",                 &deleteVpc);
        router.delete_("/v1/subnets/*",              &deleteSubnet);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/vpcs
    void listVpcs(HTTPServerRequest req, HTTPServerResponse res) {
        auto vpcs = listVpcsUseCase.execute();
        writeJson(res, serializeToJsonString(vpcsToViews(vpcs)), HTTPStatus.ok);
    }

    // POST /v1/vpcs/<id>/<name>/<cidr>/<region>
    void createVpc(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/vpcs/");
        if (segments.length != 4) {
            writeJson(res, `{ "error": "expected /v1/vpcs/<id>/<name>/<cidr>/<region>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = CreateVpcCommand(segments[0], segments[1], segments[2], segments[3]);
            auto vpc     = createVpcUseCase.execute(command);
            writeJson(res, serializeToJsonString(vpcsToViews([vpc])), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/vpcs/<id>
    void deleteVpc(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/vpcs/");
        if (segments.length == 0) {
            writeJson(res, `{ "error": "expected /v1/vpcs/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteVpcUseCase.execute(DeleteVpcCommand(segments[0]));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/subnets
    void listAllSubnets(HTTPServerRequest req, HTTPServerResponse res) {
        auto subnets = listSubnetsUseCase.execute();
        writeJson(res, serializeToJsonString(subnetsToViews(subnets)), HTTPStatus.ok);
    }

    // GET /v1/vpcs/<vpcId>/subnets
    void listSubnets(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/vpcs/");
        // segments = ["<vpcId>", "subnets"]
        if (segments.length < 1) {
            writeJson(res, `{ "error": "expected /v1/vpcs/<vpcId>/subnets" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto subnets = listSubnetsUseCase.executeByVpc(segments[0]);
            writeJson(res, serializeToJsonString(subnetsToViews(subnets)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // POST /v1/vpcs/<vpcId>/subnets/<id>/<name>/<cidr>/<az>
    void createSubnet(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/vpcs/");
        // segments = ["<vpcId>", "subnets", "<id>", "<name>", "<cidr>", "<az>"]
        if (segments.length != 6 || segments[1] != "subnets") {
            writeJson(res, `{ "error": "expected /v1/vpcs/<vpcId>/subnets/<id>/<name>/<cidr>/<az>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = CreateSubnetCommand(segments[2], segments[0], segments[3], segments[4], segments[5]);
            auto subnet  = createSubnetUseCase.execute(command);
            writeJson(res, serializeToJsonString(subnetsToViews([subnet])), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/subnets/<id>
    void deleteSubnet(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/subnets/");
        if (segments.length == 0) {
            writeJson(res, `{ "error": "expected /v1/subnets/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteSubnetUseCase.execute(DeleteSubnetCommand(segments[0]));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private VpcView[] vpcsToViews(scope const Vpc[] vpcs) {
        VpcView[] views;
        foreach (v; vpcs) {
            views ~= VpcView(v.id, v.name, v.cidr, v.region, v.state.to!string);
        }
        return views;
    }

    private SubnetView[] subnetsToViews(scope const Subnet[] subnets) {
        SubnetView[] views;
        foreach (s; subnets) {
            views ~= SubnetView(s.id, s.vpcId, s.name, s.cidr, s.availabilityZone, s.state.to!string);
        }
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        return split(requestPath[prefix.length .. $], "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
