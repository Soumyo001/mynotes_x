import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes_x/components/note_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

typedef ImportantNotesCallBack = void Function(DatabaseNotes databaseNotes);

class ImportantNotesListView extends StatefulWidget {
  final List<DatabaseNotes> notes;
  final ImportantNotesCallBack onEditCallBack;
  final ImportantNotesCallBack onDeleteCallBack;
  const ImportantNotesListView({
    super.key,
    required this.notes,
    required this.onEditCallBack,
    required this.onDeleteCallBack,
  });

  @override
  State<ImportantNotesListView> createState() => _ImportantNotesListViewState();
}

class _ImportantNotesListViewState extends State<ImportantNotesListView> {
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      itemCount: widget.notes.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemBuilder: (context, index) {
        final note = widget.notes[index];
        if (note.isImportant) {
          return NoteTile(
            index: index,
            note: note,
            onEditTap: () {
              widget.onEditCallBack(note);
            },
            onDeleteTap: () {
              widget.onDeleteCallBack(note);
            },
            hasBookmarkFunctionalities: false,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
