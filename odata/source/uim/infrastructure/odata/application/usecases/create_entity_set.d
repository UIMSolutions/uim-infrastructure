module uim.infrastructure.odata.application.usecases.create_entity_set;

import uim.infrastructure.odata.domain.entities.entity_set : EntitySet;
import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;
import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;
import uim.infrastructure.odata.application.dtos.entity_set;

class CreateEntitySetUseCase {
    private IEntitySetRepository entitySetRepo;
    private IEntityTypeRepository entityTypeRepo;

    this(IEntitySetRepository entitySetRepo, IEntityTypeRepository entityTypeRepo) {
        this.entitySetRepo = entitySetRepo;
        this.entityTypeRepo = entityTypeRepo;
    }

    EntitySetResponseDTO execute(in CreateEntitySetDTO dto) {
        auto existingSet = entitySetRepo.findByName(dto.name);
        if (existingSet !is null) {
            throw new Exception("EntitySet '" ~ dto.name ~ "' already exists");
        }

        auto entityType = entityTypeRepo.findByName(dto.entityTypeName);
        if (entityType is null) {
            throw new Exception("EntityType '" ~ dto.entityTypeName ~ "' not found");
        }

        auto es = EntitySet(dto.name, dto.entityTypeName);
        entitySetRepo.save(es);

        return EntitySetResponseDTO(es.name, es.entityTypeName);
    }
}
