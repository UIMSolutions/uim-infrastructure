/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.resource_groups;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.resource_group;
import uim.platform.ai_core.domain.ports.repositories.resource_groups;
import uim.platform.ai_core.application.dto;

class ManageResourceGroupsUseCase : UIMUseCase {
  private ResourceGroupRepository repo;

  this(ResourceGroupRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateResourceGroupRequest r) {
    if (r.resourceGroupid.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");
    if (r.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(r.resourceGroupId);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Resource group already exists");

    ResourceGroup rg;
    rg.id = r.resourceGroupId;
    rg.tenantId = r.tenantId;
    rg.status = "active";

    // Parse labels
    ResourceGroupLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ResourceGroupLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    rg.labels = labels;

    import core.time : MonoTime;

    rg.createdAt = MonoTime.currTime.ticks;

    repo.save(rg);
    return CommandResult(true, rg.id, "");
  }

  CommandResult patch(PatchResourceGroupRequest r) {
    auto rg = repo.findById(r.resourceGroupId);
    if (rg.id.isEmpty)
      return CommandResult(false, "", "Resource group not found");

    ResourceGroupLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ResourceGroupLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    rg.labels = labels;

    repo.update(rg);
    return CommandResult(true, rg.id, "");
  }

  ResourceGroup get_(ResourceGroupId id) {
    return repo.findById(id);
  }

  ResourceGroup[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(ResourceGroupId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Resource group not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
