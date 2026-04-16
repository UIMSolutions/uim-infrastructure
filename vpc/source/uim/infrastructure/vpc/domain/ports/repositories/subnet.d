module vpc_service.domain.ports.repositories.subnet;

import vpc_service.domain.entities.subnet : Subnet;

interface ISubnetRepository {
    void save(in Subnet subnet);
    void remove(string id);
    Subnet[] list();
    Subnet[] listByVpc(string vpcId);
    Subnet* findById(string id);
}
