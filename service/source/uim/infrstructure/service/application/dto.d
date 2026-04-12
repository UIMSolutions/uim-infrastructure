module uim.platform.service.application.dto;

@safe:
struct CommandResult {
  bool success;
  string id;
  string error;
  // TODO: Success??
  bool isSuccess() const {
    return error.length == 0;
  }
}

// struct CommandResult {
//   bool success;
//   string id;
//   string error;
// }
