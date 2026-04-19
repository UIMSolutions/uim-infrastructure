module uim.infrastructure.odata.application.usecases.list_entity_types;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import uim.infrastructure.odata.domain.entities.entity_type : EntityType;
import uim.infrastructure.odata.domain.entities.property : EdmType;
import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;
import uim.infrastructure.odata.application.dtos.entity_type;

class ListEntityTypesUseCase {
    private IEntityTypeRepository repo;

    this(IEntityTypeRepository repo) {
        this.repo = repo;
    }

    EntityTypeResponseDTO[] execute() {
        return repo.list().map!(et => toResponse(et)).array;
    }

    private EntityTypeResponseDTO toResponse(in EntityType et) {
        PropertyDTO[] props;
        foreach (p; et.properties) {
            props ~= PropertyDTO(p.name, edmTypeToString(p.type), p.nullable, p.defaultValue, p.maxLength);
        }
        NavigationPropertyDTO[] navProps;
        foreach (np; et.navigationProperties) {
            navProps ~= NavigationPropertyDTO(np.name, np.targetEntityType, np.multiplicity.to!string, np.partner);
        }
        return EntityTypeResponseDTO(
            et.name, et.namespace_, et.fullName(), et.keyProperties.dup, props, navProps,
        );
    }

    private string edmTypeToString(EdmType t) {
        final switch (t) {
            case EdmType.string_: return "Edm.String";
            case EdmType.int32: return "Edm.Int32";
            case EdmType.int64: return "Edm.Int64";
            case EdmType.boolean_: return "Edm.Boolean";
            case EdmType.double_: return "Edm.Double";
            case EdmType.decimal_: return "Edm.Decimal";
            case EdmType.dateTimeOffset: return "Edm.DateTimeOffset";
            case EdmType.guid: return "Edm.Guid";
            case EdmType.binary: return "Edm.Binary";
            case EdmType.single: return "Edm.Single";
            case EdmType.byte_: return "Edm.Byte";
            case EdmType.stream: return "Edm.Stream";
        }
    }
}
