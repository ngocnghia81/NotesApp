import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/modal_class/attachment.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  int color;
  int priority;
  List<Attachment> attachments = [];
  bool isLoading = true;
  bool _isSaving = false;

  NoteDetailState(this.note, this.appBarTitle)
      : color = note.color,
        priority = note.priority;

  @override
  void initState() {
    super.initState();
    titleController.text = note.title;
    descriptionController.text = note.description ?? '';

    // Load attachments if note has an id (editing existing note)
    if (note.id != null) {
      _loadAttachments();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Load attachments for the note
  Future<void> _loadAttachments() async {
    if (note.id == null) return;

    try {
      final attachmentsList = await helper.getAttachmentsForNote(note.id!);
      if (mounted) {
        setState(() {
          attachments = attachmentsList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error loading attachments: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.appBarTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete' && note?.id != null) {
                _confirmDeleteDialog();
              } else if (value == 'share') {
                // TODO: Implement share functionality
                _showSnackBar('Chức năng chia sẻ đang được phát triển');
              }
            },
            itemBuilder: (context) => [
              if (note?.id != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa ghi chú'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: const [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Chia sẻ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: titleController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: TextFormField(
                        controller: descriptionController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Nội dung',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        'Chọn mức độ ưu tiên',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    PriorityPicker(
                      selectedIndex: _getPriorityAsInt(),
                      onTap: (selectedIndex) {
                        if (!mounted) return;
                        setState(() {
                          priority = 3 - selectedIndex;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        'Chọn màu ghi chú',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    ColorPicker(
                      selectedIndex: color ?? 0,
                      onTap: (selectedColor) {
                        if (!mounted) return;
                        setState(() {
                          color = selectedColor;
                        });
                      },
                    ),

                    // Attachment section
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tệp đính kèm (${attachments.length})',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo),
                                tooltip: 'Thêm hình ảnh',
                                onPressed: _pickImage,
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                tooltip: 'Thêm tệp',
                                onPressed: _pickFile,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // List of attachments
                    if (attachments.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attachments.length,
                        itemBuilder: (context, index) {
                          final attachment = attachments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: _buildAttachmentItem(attachment),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isSaving
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                _saveNote();
              },
            ),
    );
  }

  Widget _buildAttachmentItem(Attachment attachment) {
    IconData iconData;
    Color iconColor;

    if (attachment.isImage) {
      iconData = Icons.image;
      iconColor = Colors.blue;
    } else if (attachment.isPdf) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (attachment.isDocument) {
      iconData = Icons.description;
      iconColor = Colors.orange;
    } else if (attachment.isAudio) {
      iconData = Icons.audio_file;
      iconColor = Colors.purple;
    } else if (attachment.isVideo) {
      iconData = Icons.videocam;
      iconColor = Colors.green;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: attachment.isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(attachment.filePath),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(iconData, size: 30, color: iconColor);
                  },
                ),
              )
            : Icon(iconData, size: 30, color: iconColor),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(attachment.formattedFileSize),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteAttachment(attachment),
        ),
        onTap: () => _openAttachment(attachment),
      ),
    );
  }

  void _openAttachment(Attachment attachment) {
    if (!attachment.fileExists) {
      _showSnackBar('Tệp đã bị xóa hoặc di chuyển');
      return;
    }

    if (attachment.isImage) {
      if (!mounted) return;
      _showDialogSafely(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(attachment.fileName),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              Image.file(File(attachment.filePath)),
            ],
          ),
        ),
      );
    } else {
      _showSnackBar('Chức năng xem tệp đang được phát triển');
      // TODO: Implement file viewing functionality
    }
  }

  // Chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage() async {
    if (!mounted) return;

    ImageSource? source;

    // Kiểm tra nếu đang chạy trên Linux
    if (Platform.isLinux) {
      // Trên Linux: chỉ chọn ảnh từ thư viện, không dùng camera
      source = ImageSource.gallery;
    } else {
      // Trên các nền tảng khác: hiển thị dialog cho người dùng chọn
      source = await _showDialogSafely<ImageSource?>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Chọn nguồn ảnh'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                child: const Text('Chụp ảnh mới'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                child: const Text('Chọn từ thư viện'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Hủy'),
              ),
            ],
          );
        },
      );
    }

    if (source == null || !mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null && mounted) {
        final saveDir = await _getAttachmentDirectory();
        final newPath = path.join(saveDir.path, path.basename(image.path));
        final savedFile = await File(image.path).copy(newPath);

        if (note.id != null) {
          // Nếu ghi chú đã tồn tại, thêm attachment vào DB
          final attachment = Attachment.fromFile(savedFile, note.id!);
          final attachmentId = await helper.insertAttachment(attachment);
          setState(() {
            attachments.add(Attachment.withId(
              attachmentId,
              attachment.noteId,
              attachment.filePath,
              attachment.fileName,
              attachment.fileType,
              attachment.fileSize,
              attachment.createdAt,
            ));
          });
        } else {
          // Nếu ghi chú chưa tồn tại, lưu tạm thời
          final tempAttachment = Attachment.fromFile(savedFile, -1);
          setState(() {
            attachments.add(tempAttachment);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        _showSnackBar('Không thể thêm ảnh: ${e.toString()}');
      }
    }
  }

  // Chọn tệp từ bộ nhớ
  Future<void> _pickFile() async {
    if (!mounted) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null && mounted) {
        final originalFile = File(result.files.single.path!);
        final saveDir = await _getAttachmentDirectory();
        final newPath =
            path.join(saveDir.path, path.basename(originalFile.path));
        final savedFile = await originalFile.copy(newPath);

        if (note.id != null) {
          // Nếu ghi chú đã tồn tại, thêm attachment vào DB
          final attachment = Attachment.fromFile(savedFile, note.id!);
          final attachmentId = await helper.insertAttachment(attachment);
          setState(() {
            attachments.add(Attachment.withId(
              attachmentId,
              attachment.noteId,
              attachment.filePath,
              attachment.fileName,
              attachment.fileType,
              attachment.fileSize,
              attachment.createdAt,
            ));
          });
        } else {
          // Nếu ghi chú chưa tồn tại, lưu tạm thời
          final tempAttachment = Attachment.fromFile(savedFile, -1);
          setState(() {
            attachments.add(tempAttachment);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        _showSnackBar('Không thể thêm tệp: $e');
      }
    }
  }

  // Lấy thư mục để lưu tệp đính kèm
  Future<Directory> _getAttachmentDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    return attachmentsDir;
  }

  // Xóa tệp đính kèm
  void _deleteAttachment(Attachment attachment) async {
    if (!mounted) return;

    final confirm = await _showDialogSafely<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tệp đính kèm'),
          content: const Text('Bạn có chắc chắn muốn xóa tệp đính kèm này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        // Xóa file trên disk
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Xóa khỏi database nếu đã có ID
        if (attachment.attachmentId != null) {
          await helper.deleteAttachment(attachment.attachmentId!);
        }

        // Cập nhật UI
        setState(() {
          attachments.remove(attachment);
        });

        _showSnackBar('Đã xóa tệp đính kèm');
      } catch (e) {
        debugPrint('Error deleting attachment: $e');
        if (mounted) {
          _showSnackBar('Không thể xóa tệp đính kèm: $e');
        }
      }
    }
  }

  // Save note to database
  void _saveNote() async {
    if (!mounted) return;

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update note object
      note.title = titleController.text;
      note.description = descriptionController.text;
      note.priority = priority;
      note.color = color;
      note.date = DateFormat.yMMMd().format(DateTime.now());

      int result;
      if (note.id != null) {
        // Update the note
        result = await helper.updateNote(note);
      } else {
        // Insert new note
        result = await helper.insertNote(note);
        note.id = result; // Update note with new ID

        // Add all pending attachments
        for (var attachment in attachments) {
          attachment.noteId = result;
          await helper.insertAttachment(attachment);
        }
      }

      if (result != 0 && mounted) {
        setState(() {
          _isSaving = false;
        });
        _showSnackBar('Đã lưu ghi chú');
        _goBack(true);
      } else {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          _showSnackBar('Có lỗi xảy ra khi lưu ghi chú');
        }
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showSnackBar('Có lỗi xảy ra: $e');
      }
    }
  }

  // Confirm delete dialog
  Future<void> _confirmDeleteDialog() async {
    if (note.id == null || !mounted) return;

    final confirm = await _showDialogSafely<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa ghi chú'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        // Delete all attachments first
        await helper.deleteAllAttachmentsForNote(note.id!);

        // Delete physical files
        for (var attachment in attachments) {
          final file = File(attachment.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Delete note
        await helper.deleteNote(note.id!);

        if (mounted) {
          _showSnackBar('Đã xóa ghi chú');
          _goBack(true);
        }
      } catch (e) {
        debugPrint('Error deleting note: $e');
        if (mounted) {
          _showSnackBar('Không thể xóa ghi chú: $e');
        }
      }
    }
  }

  void _goBack([bool refreshList = false]) {
    Navigator.pop(context, refreshList);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<T?> _showDialogSafely<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) async {
    if (!mounted) return null;
    return showDialog<T>(context: context, builder: builder);
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  // Returns the priority text
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Cao';
      case 2:
        return 'Vừa';
      case 3:
        return 'Thấp';
      default:
        return 'Thấp';
    }
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  int _getPriorityAsInt() {
    return 3 - (priority ?? 3);
  }
}
