module vpc_service.domain.entities.vpc;

enum VpcState {
    pending,
    available,
    deleted
}

struct Vpc {
    string id;
    string name;
    string cidr;
    string region;
    VpcState state;
}

unittest {
    auto vpc = Vpc("vpc-001", "production", "10.0.0.0/16", "eu-west-1", VpcState.available);
    assert(vpc.id == "vpc-001");
    assert(vpc.cidr == "10.0.0.0/16");
    assert(vpc.state == VpcState.available);
}
