import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../main.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;
  int axisCount = 2;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    PreferredSizeWidget myAppBar() {
      return AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: noteList.isEmpty
            ? null
            : IconButton(
                splashRadius: 22,
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () async {
                  if (!mounted) return;

                  final Note? result = await showSearch<Note?>(
                      context: context, delegate: NotesSearch(notes: noteList));
                  if (result != null && mounted) {
                    navigateToDetail(result, 'Edit Note');
                  }
                },
              ),
        actions: <Widget>[
          // Nút chuyển đổi chế độ sáng/tối
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () async {
              if (mounted) {
                await themeProvider.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Đã chuyển sang chế độ ${isDark ? "sáng" : "tối"}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          noteList.isEmpty
              ? Container()
              : IconButton(
                  splashRadius: 22,
                  icon: Icon(
                    axisCount == 2 ? Icons.list : Icons.grid_on,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      axisCount = axisCount == 2 ? 4 : 2;
                    });
                  },
                )
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: myAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noteList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Chưa có ghi chú nào. Hãy thêm ghi chú mới!',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.background,
                  child: getNotesList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0), 'Add Note');
        },
        tooltip: 'Add Note',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget getNotesList() {
    return MasonryGridView.count(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: axisCount,
      itemCount: count,
      padding: const EdgeInsets.all(8),
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(noteList[index], 'Edit Note');
        },
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colors[noteList[index].color].withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.7 : 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        noteList[index].title,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getPriorityColor(noteList[index].priority)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        getPriorityText(noteList[index].priority),
                        style: TextStyle(
                          color: getPriorityColor(noteList[index].priority),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (noteList[index].description?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      noteList[index].description ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        noteList[index].date,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
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

  // Returns the priority icon
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

  void navigateToDetail(Note note, String title) async {
    if (!mounted) return;

    bool? result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true && mounted) {
      updateListView();
    }
  }

  void updateListView() {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final Future<Database> dbFuture = databaseHelper.initializeDatabase();
      dbFuture.then((database) {
        Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
        noteListFuture.then((noteList) {
          if (mounted) {
            setState(() {
              this.noteList = noteList;
              count = noteList.length;
              isLoading = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            debugPrint('Lỗi khi lấy danh sách ghi chú: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Có lỗi xảy ra khi tải dữ liệu'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }).catchError((error) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          debugPrint('Lỗi khi khởi tạo cơ sở dữ liệu: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra khi kết nối đến cơ sở dữ liệu'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Lỗi không xác định khi cập nhật danh sách: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi không xác định xảy ra'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
