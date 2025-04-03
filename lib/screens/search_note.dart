import 'package:flutter/material.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/utils/widgets.dart';

class NotesSearch extends SearchDelegate<Note?> {
  final List<Note> notes;
  List<Note> filteredNotes = [];
  NotesSearch({required this.notes});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.colorScheme.primary,
        selectionColor: theme.colorScheme.primary.withOpacity(0.4),
        selectionHandleColor: theme.colorScheme.primary,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    try {
      if (query == '') {
        return _buildEmptySearchState(context);
      } else {
        filteredNotes = [];
        getFilteredList(notes);
        if (filteredNotes.isEmpty) {
          return _buildNoResultsFoundState(context);
        } else {
          return _buildSearchResultsList(context);
        }
      }
    } catch (e) {
      debugPrint('Lỗi trong tìm kiếm: $e');
      return _buildErrorState(context, e.toString());
    }
  }

  Widget _buildEmptySearchState(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nhập từ khóa để tìm kiếm ghi chú',
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      )),
    );
  }

  Widget _buildNoResultsFoundState(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sentiment_dissatisfied,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả phù hợp',
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      )),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi khi tìm kiếm',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      )),
    );
  }

  Widget _buildSearchResultsList(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors[filteredNotes[index].color],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.note,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              title: Text(
                filteredNotes[index].title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: filteredNotes[index].description?.isNotEmpty ?? false
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        filteredNotes[index].description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : null,
              onTap: () {
                close(context, filteredNotes[index]);
              },
            ),
          );
        },
      ),
    );
  }

  List<Note> getFilteredList(List<Note> note) {
    try {
      for (int i = 0; i < note.length; i++) {
        if (note[i].title.toLowerCase().contains(query.toLowerCase()) ||
            (note[i].description?.toLowerCase().contains(query.toLowerCase()) ??
                false)) {
          filteredNotes.add(note[i]);
        }
      }
      return filteredNotes;
    } catch (e) {
      debugPrint('Lỗi khi lọc danh sách ghi chú: $e');
      return [];
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
