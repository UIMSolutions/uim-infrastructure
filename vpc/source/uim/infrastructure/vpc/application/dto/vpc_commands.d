module vpc_service.application.dto.vpc_commands;

struct CreateVpcCommand {
    string id;
    string name;
    string cidr;
    string region;
}

struct DeleteVpcCommand {
    string id;
}

struct CreateSubnetCommand {
    string id;
    string vpcId;
    string name;
    string cidr;
    string availabilityZone;
}

struct DeleteSubnetCommand {
    string id;
}
