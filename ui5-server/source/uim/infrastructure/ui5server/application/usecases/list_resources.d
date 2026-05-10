module uim.infrastructure.ui5server.application.usecases.list_resources;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;
import uim.infrastructure.ui5server.application.dtos.resource : ResourceResponseDTO, DirectoryListingDTO;

class ListResourcesUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    DirectoryListingDTO execute(string directoryPath) {
        ResourceResponseDTO[] entries;
        foreach (r; repo.findByDirectory(directoryPath)) {
            entries ~= ResourceResponseDTO(
                r.path,
                r.contentType,
                r.size,
                r.lastModified,
                r.isDirectory,
            );
        }
        return DirectoryListingDTO(directoryPath, entries);
    }
}
