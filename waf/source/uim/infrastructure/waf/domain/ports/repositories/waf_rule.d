/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.waf.domain.ports.repositories.waf_rule;

import uim.infrastructure.waf.domain.entities.waf_rule : WafRule;

interface IWafRuleRepository {
    void save(in WafRule rule);
    void remove(string id);
    WafRule[] list();
    WafRule* findById(string id);
    WafRule[] findEnabled();
}
