import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes_x/components/note_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

typedef BookmarkedNoteCallBack = void Function(DatabaseNotes databaseNotes);

class BookmarkedNotesListView extends StatefulWidget {
  final List<DatabaseNotes> notes;
  final BookmarkedNoteCallBack onEditCallBack;
  final BookmarkedNoteCallBack onDeleteCallBack;
  const BookmarkedNotesListView({
    super.key,
    required this.notes,
    required this.onEditCallBack,
    required this.onDeleteCallBack,
  });

  @override
  State<BookmarkedNotesListView> createState() =>
      _BookmarkedNotesListViewState();
}

class _BookmarkedNotesListViewState extends State<BookmarkedNotesListView> {
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      shrinkWrap: true,
      itemCount: widget.notes.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemBuilder: (context, index) {
        final note = widget.notes[index];
        if (note.isBookmarked) {
          return NoteTile(
            index: index,
            note: note,
            hasBookmarkFunctionalities: true,
            onEditTap: () {
              widget.onEditCallBack(note);
            },
            onDeleteTap: () {
              widget.onDeleteCallBack(note);
            },
            isBookmarkTapped: note.isBookmarked,
            onBookmarkTap: () async {
              setState(() {
                note.isBookmarked = !note.isBookmarked;
              });
              await _notesService.updateNoteBookmark(
                note: note,
                isBookmarked: note.isBookmarked,
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
