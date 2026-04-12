/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.classes.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class SAPRepository(T) {
  // Placeholder for repository methods
  // This class can be extended to implement specific data access logic for the service

  void save(T item) {
    // 
  }

  void update(T item) {
    // 
  }
}

class MemoryTenantRepository(TEntity, TId) { // }: IBaseRepository!(TEntity, TId) {
  private TEntity[TId][TenantId] store;

  bool existsByTenant(TenantId tenantId) {
    return (tenantId in store) && !store[tenantId].empty;
  }

  TEntity[] findByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return null;

    return store[tenantId].byValue.array;
  }

  bool existsById(TenantId tenantId, TId id) {
    return (existsByTenant(tenantId) && (id in store[tenantId]));
  }

  TEntity findById(TenantId tenantId, TId id) {
    if (!existsById(tenantId, id))
      return TEntity.init;

    return store[tenantId][id];
  }

  void save(TEntity entity) {
    if (!existsByTenant(entity.tenantId)) {
      TEntity[TId] entities;
      store[entity.tenantId] = entities;
    }
    store[entity.tenantId][entity.id] = entity;
  }

  void save(TenantId tenantId, TEntity entity) {
    entity.tenantId = tenantId;
    save(entity);
  }

  void update(TEntity entity) {
    if (existsById(entity.tenantId, entity.id)) {
      store[entity.tenantId][entity.id] = entity;
    }
  }

  void remove(TenantId tenantId, bool onlyIfEmpty = true) {
    if (!existsByTenant(tenantId))
      return;

    if (onlyIfEmpty && !store[tenantId].empty)
      return;

    store.remove(tenantId);
  }
  
  void remove(TenantId tenantId, TId id) {
    if (!existsById(tenantId, id))
      return;

    store[tenantId].remove(id);
    if (store[tenantId].empty) {
      store.remove(tenantId);
    }
  }
}
