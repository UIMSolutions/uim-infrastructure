module uim.platform.service.mixins.domain;

import uim.platform.service;

mixin(ShowModule!());
@safe:

mixin template DomainId() {
    void opAssign(UUID newValue) {
        this.value = newValue.toString();
    }

    void opAssign(string newValue) {
        this.value = newValue;
    }


    bool isNull() const {
        return value is null;
    }

    bool isEmpty() const {
        return value.length == 0;
    }

    string toString() const {
        return value;
    }

    Json toJson() const {
        return Json(value);
    }
}
