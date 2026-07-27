/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.service.mixins.domain;

import uim.infrastructure.service;

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
