module fs_service.application.dto.file_command;

struct UploadFileCommand {
    string  name;
    string  contentType;
    ubyte[] data;
}

struct DeleteFileCommand {
    string id;
}

struct DownloadFileQuery {
    string id;
}
