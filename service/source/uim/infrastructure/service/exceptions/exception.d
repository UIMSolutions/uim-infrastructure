/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.service.exceptions.exception;

import uim.infrastructure.service;

mixin(ShowModule!());

@safe:

class UIMException : Exception {
  this(string msg) {
    super(msg);
  }

  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}
///
unittest {
  UIMException ex1 = new UIMException("Test message");
  assert(ex1.message == "Test message");

  UIMException ex2 = new UIMException("Test message", "testfile.d", 123);
  assert(ex2.message == "Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}
