module uim.infrastructure.odata.application.usecases.create_entity;

import uim.infrastructure.odata.domain.entities.entity : Entity;
import uim.infrastructure.odata.domain.entities.entity_type : EntityType;
import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;
import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;
import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;
import uim.infrastructure.odata.application.dtos.entity;

class CreateEntityUseCase {
    private IEntityRepository entityRepo;
    private IEntitySetRepository entitySetRepo;
    private IEntityTypeRepository entityTypeRepo;

    this(IEntityRepository entityRepo, IEntitySetRepository entitySetRepo, IEntityTypeRepository entityTypeRepo) {
        this.entityRepo = entityRepo;
        this.entitySetRepo = entitySetRepo;
        this.entityTypeRepo = entityTypeRepo;
    }

    EntityResponseDTO execute(in CreateEntityDTO dto) {
        auto entitySet = entitySetRepo.findByName(dto.entitySetName);
        if (entitySet is null) {
            throw new Exception("EntitySet '" ~ dto.entitySetName ~ "' not found");
        }

        auto entityType = entityTypeRepo.findByName(entitySet.entityTypeName);
        if (entityType is null) {
            throw new Exception("EntityType '" ~ entitySet.entityTypeName ~ "' not found");
        }

        auto id = extractId(dto.properties, entityType.keyProperties);

        auto entity = Entity(
            dto.entitySetName,
            entitySet.entityTypeName,
            dto.properties.dup,
            id,
        );

        entityRepo.save(dto.entitySetName, entity);

        return EntityResponseDTO(
            entity.entitySetName,
            entity.entityTypeName,
            entity.id,
            entity.properties.dup,
        );
    }

    private string extractId(in string[string] props, in string[] keyProps) {
        string id;
        foreach (k; keyProps) {
            if (k in props) {
                if (id.length > 0) id ~= ",";
                id ~= props[k];
            }
        }
        return id;
    }
}
