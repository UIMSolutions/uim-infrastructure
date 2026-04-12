 module uim.infrastructure.service.interfaces.repository;

import uim.infrastructure.service;

mixin(ShowModule!());

@safe:

interface IBaseRepository(TEntity, TId) {
  bool existsById(TId id);
  TEntity findById(TId id);

  size_t countAll();

  void save(TEntity entity);
  void update(TEntity entity);
  void remove(TId id);
}

interface ITenantRepository(TEntity, TId) : IBaseRepositiry!(TEntity, TId) {
  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);
  size_t countByTenant(TenantId tenantId);

  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);

  void save(TenantId tenantId, TEntity entity);
  void remove(TenantId tenantId, TId id);
}