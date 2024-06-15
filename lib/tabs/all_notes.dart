import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/notes_list_view.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/dialogs/delete_dialog.dart';

class AllNotes extends StatefulWidget {
  final DatabaseUser user;
  final List<DatabaseNotes> notes;
  final String? payload;
  const AllNotes({
    super.key,
    required this.user,
    required this.notes,
    this.payload,
  });

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
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
          horizontal: 3.0,
          vertical: 8.0,
        ),
        child: NotesListView(
          notes: widget.notes,
          editCallBack: (databaseNotes) {
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
          deleteCallBack: (databaseNotes) async {
            Navigator.of(context).pop();
            final shouldDelete = await showDeleteDialog(context: context);
            if (shouldDelete) {
              await _notesService.deleteNote(id: databaseNotes.noteID);
            }
          },
        ),
      ),
    );
  }
}
