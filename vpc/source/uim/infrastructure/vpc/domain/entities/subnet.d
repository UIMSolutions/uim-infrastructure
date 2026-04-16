module vpc_service.domain.entities.subnet;

import vpc_service.domain.entities.vpc : VpcState;

alias SubnetState = VpcState;

struct Subnet {
    string id;
    string vpcId;
    string name;
    string cidr;
    string availabilityZone;
    SubnetState state;
}

unittest {
    auto subnet = Subnet("subnet-001", "vpc-001", "public-a", "10.0.1.0/24", "eu-west-1a", SubnetState.available);
    assert(subnet.id == "subnet-001");
    assert(subnet.vpcId == "vpc-001");
    assert(subnet.cidr == "10.0.1.0/24");
}
