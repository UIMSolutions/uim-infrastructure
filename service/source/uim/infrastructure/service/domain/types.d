module uim.infrastructure.service.domain.types;

import uim.infrastructure.service;

mixin(ShowModule!());

@safe:

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}