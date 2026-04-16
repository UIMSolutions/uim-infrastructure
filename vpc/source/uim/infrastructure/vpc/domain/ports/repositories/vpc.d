module vpc_service.domain.ports.repositories.vpc;

import vpc_service.domain.entities.vpc : Vpc;

interface IVpcRepository {
    void save(in Vpc vpc);
    void remove(string id);
    Vpc[] list();
    Vpc* findById(string id);
}
