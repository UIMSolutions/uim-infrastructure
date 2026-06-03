module uim.infrastructure.manila.domain.ports.repositories.share_type;

import uim.infrastructure.manila.domain.entities.share_type : ShareType;

interface IShareTypeRepository {
    ShareType[] list();
    ShareType* findById(string id);
}