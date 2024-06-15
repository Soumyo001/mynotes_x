import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/notes_list_view_bookmark.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/dialogs/delete_dialog.dart';

class BookmarkedNotes extends StatefulWidget {
  final List<DatabaseNotes> notes;
  final DatabaseUser user;
  const BookmarkedNotes({
    super.key,
    required this.notes,
    required this.user,
  });

  @override
  State<BookmarkedNotes> createState() => _BookmarkedNotesState();
}

class _BookmarkedNotesState extends State<BookmarkedNotes> {
  late final NotesService _notesService;
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 8,
        ),
        child: BookmarkedNotesListView(
          notes: widget.notes,
          onEditCallBack: (databaseNotes) {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateUpdateNewNote(
                  user: widget.user,
                  note: databaseNotes,
                ),
              ),
            );
          },
          onDeleteCallBack: (databaseNotes) async {
            Navigator.of(context).pop();
            final shouldDelete = await showDeleteDialog(context: context);
            if (shouldDelete) {
              _notesService.deleteNote(id: databaseNotes.noteID);
            }
          },
        ),
      ),
    );
  }
}
