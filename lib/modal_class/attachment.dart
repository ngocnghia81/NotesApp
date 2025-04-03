import 'dart:io';
import 'package:path/path.dart' as path;

class Attachment {
  int? _attachmentId;
  int _noteId;
  String _filePath;
  String _fileName;
  String _fileType;
  int _fileSize;
  String _createdAt;

  // Constructor
  Attachment(
    this._noteId,
    this._filePath,
    this._fileName,
    this._fileType,
    this._fileSize,
    this._createdAt,
  );

  // Constructor with id
  Attachment.withId(
    this._attachmentId,
    this._noteId,
    this._filePath,
    this._fileName,
    this._fileType,
    this._fileSize,
    this._createdAt,
  );

  // Getters
  int? get attachmentId => _attachmentId;
  int get noteId => _noteId;
  String get filePath => _filePath;
  String get fileName => _fileName;
  String get fileType => _fileType;
  int get fileSize => _fileSize;
  String get createdAt => _createdAt;

  // Setters
  set noteId(int newNoteId) {
    _noteId = newNoteId;
  }

  set filePath(String newFilePath) {
    _filePath = newFilePath;
  }

  set fileName(String newFileName) {
    _fileName = newFileName;
  }

  set fileType(String newFileType) {
    _fileType = newFileType;
  }

  set fileSize(int newFileSize) {
    _fileSize = newFileSize;
  }

  set createdAt(String newCreatedAt) {
    _createdAt = newCreatedAt;
  }

  // Convert Attachment object to Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (attachmentId != null) {
      map['attachment_id'] = _attachmentId;
    }
    map['note_id'] = _noteId;
    map['file_path'] = _filePath;
    map['file_name'] = _fileName;
    map['file_type'] = _fileType;
    map['file_size'] = _fileSize;
    map['created_at'] = _createdAt;
    return map;
  }

  // Extract Attachment object from Map object
  Attachment.fromMapObject(Map<String, dynamic> map)
      : _attachmentId = map['attachment_id'],
        _noteId = map['note_id'],
        _filePath = map['file_path'],
        _fileName = map['file_name'],
        _fileType = map['file_type'],
        _fileSize = map['file_size'],
        _createdAt = map['created_at'];

  // Utility methods
  bool get fileExists => File(_filePath).existsSync();

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
      .contains(_fileType.toLowerCase());

  bool get isPdf => _fileType.toLowerCase() == 'pdf';

  bool get isDocument =>
      ['doc', 'docx', 'txt', 'rtf', 'pdf'].contains(_fileType.toLowerCase());

  bool get isAudio =>
      ['mp3', 'wav', 'aac', 'ogg'].contains(_fileType.toLowerCase());

  bool get isVideo =>
      ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(_fileType.toLowerCase());

  // Helper to create an attachment from a file
  static Attachment fromFile(File file, int noteId) {
    final fileName = path.basename(file.path);
    final fileSize = file.lengthSync();
    final fileExt = path.extension(file.path).replaceAll('.', '');
    final now = DateTime.now().toIso8601String();

    return Attachment(
      noteId,
      file.path,
      fileName,
      fileExt,
      fileSize,
      now,
    );
  }

  // Helper to format file size for display
  String get formattedFileSize {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = _fileSize.toDouble();

    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return size.toStringAsFixed(1) + ' ' + suffixes[i];
  }
}
