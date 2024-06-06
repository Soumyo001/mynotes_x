import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/notes_list_view.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/delete_dialog.dart';

enum NoteViewOptions { edit, delete }

class AllNotes extends StatefulWidget {
  final DatabaseUser user;
  final String? payload;
  const AllNotes({
    super.key,
    required this.user,
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
    return StreamBuilder(
      stream: _notesService.allNotes,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final notes = snapshot.data as List<DatabaseNotes>;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3.0,
                    vertical: 8.0,
                  ),
                  child: NotesListView(
                    notes: notes,
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
                      final shouldDelete =
                          await showDeleteDialog(context: context);
                      if (shouldDelete) {
                        await _notesService.deleteNote(
                            id: databaseNotes.noteID);
                      }
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              );
            }
          default:
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            );
        }
      },
    );
  }
}
