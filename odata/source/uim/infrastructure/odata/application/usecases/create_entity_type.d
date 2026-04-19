module uim.infrastructure.odata.application.usecases.create_entity_type;

import std.conv : to;
import uim.infrastructure.odata.domain.entities.entity_type : EntityType;
import uim.infrastructure.odata.domain.entities.property : Property, EdmType;
import uim.infrastructure.odata.domain.entities.navigation_property : NavigationProperty, Multiplicity;
import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;
import uim.infrastructure.odata.application.dtos.entity_type;

class CreateEntityTypeUseCase {
    private IEntityTypeRepository repo;

    this(IEntityTypeRepository repo) {
        this.repo = repo;
    }

    EntityTypeResponseDTO execute(in CreateEntityTypeDTO dto) {
        auto existing = repo.findByName(dto.name);
        if (existing !is null) {
            throw new Exception("EntityType '" ~ dto.name ~ "' already exists");
        }

        Property[] props;
        foreach (p; dto.properties) {
            props ~= Property(p.name, parseEdmType(p.type), p.nullable, p.defaultValue, p.maxLength);
        }

        NavigationProperty[] navProps;
        foreach (np; dto.navigationProperties) {
            navProps ~= NavigationProperty(np.name, np.targetEntityType, parseMultiplicity(np.multiplicity), np.partner);
        }

        auto entityType = EntityType(
            dto.name,
            dto.namespace_,
            dto.keyProperties.dup,
            props,
            navProps,
        );

        repo.save(entityType);
        return toResponse(entityType);
    }

    private EdmType parseEdmType(string t) {
        switch (t) {
            case "Edm.String": return EdmType.string_;
            case "Edm.Int32": return EdmType.int32;
            case "Edm.Int64": return EdmType.int64;
            case "Edm.Boolean": return EdmType.boolean_;
            case "Edm.Double": return EdmType.double_;
            case "Edm.Decimal": return EdmType.decimal_;
            case "Edm.DateTimeOffset": return EdmType.dateTimeOffset;
            case "Edm.Guid": return EdmType.guid;
            case "Edm.Binary": return EdmType.binary;
            case "Edm.Single": return EdmType.single;
            case "Edm.Byte": return EdmType.byte_;
            case "Edm.Stream": return EdmType.stream;
            default: return EdmType.string_;
        }
    }

    private Multiplicity parseMultiplicity(string m) {
        if (m == "many" || m == "*") return Multiplicity.many;
        return Multiplicity.one;
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
            et.name,
            et.namespace_,
            et.fullName(),
            et.keyProperties.dup,
            props,
            navProps,
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
