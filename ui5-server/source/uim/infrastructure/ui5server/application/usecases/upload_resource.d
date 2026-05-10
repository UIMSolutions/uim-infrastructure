module uim.infrastructure.ui5server.application.usecases.upload_resource;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;
import uim.infrastructure.ui5server.domain.entities.resource : Resource;
import uim.infrastructure.ui5server.application.dtos.resource : UploadResourceDTO, ResourceResponseDTO;

class UploadResourceUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    ResourceResponseDTO execute(UploadResourceDTO dto) {
        import std.conv : to;

        auto resource = Resource(
            dto.path,
            dto.contentType,
            dto.content.length.to!ulong,
            "2026-01-01T00:00:00Z",
            dto.content,
            dto.isDirectory,
        );

        repo.save(resource);

        return ResourceResponseDTO(
            resource.path,
            resource.contentType,
            resource.size,
            resource.lastModified,
            resource.isDirectory,
        );
    }
}
