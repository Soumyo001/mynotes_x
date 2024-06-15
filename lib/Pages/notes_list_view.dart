import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes_x/components/note_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

typedef NoteCallBack = void Function(DatabaseNotes databaseNote);

class NotesListView extends StatefulWidget {
  final List<DatabaseNotes> notes;
  final NoteCallBack deleteCallBack;
  final NoteCallBack editCallBack;
  const NotesListView({
    super.key,
    required this.notes,
    required this.deleteCallBack,
    required this.editCallBack,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
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
        return NoteTile(
          index: index,
          note: note,
          hasBookmarkFunctionalities: true,
          onEditTap: () {
            widget.editCallBack(note);
          },
          onDeleteTap: () {
            widget.deleteCallBack(note);
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
      },
    );
  }
}
