import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/notes_list_view_important.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/dialogs/delete_dialog.dart';

class ImportantNotes extends StatefulWidget {
  final DatabaseUser user;
  final List<DatabaseNotes> notes;
  const ImportantNotes({
    super.key,
    required this.user,
    required this.notes,
  });

  @override
  State<ImportantNotes> createState() => _ImportantNotesState();
}

class _ImportantNotesState extends State<ImportantNotes> {
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
        child: ImportantNotesListView(
          notes: widget.notes,
          onEditCallBack: (databaseNotes) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateUpdateNewNote(
                  user: widget.user,
                  note: databaseNotes,
                ),
              ),
            );
          },
          onDeleteCallBack: (databaseNotes) async {
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
