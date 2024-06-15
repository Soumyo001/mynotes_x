import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/tags_list_view.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

class UserTags extends StatefulWidget {
  final DatabaseUser? user;
  const UserTags({
    super.key,
    this.user,
  });

  @override
  State<UserTags> createState() => _UserTagsState();
}

class _UserTagsState extends State<UserTags> {
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: const Text(
          'N O T E S',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder(
        stream: _notesService.allTags,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final List<DatabaseTagsForUser> tags =
                    snapshot.data as List<DatabaseTagsForUser>;
                return Center(
                  child: TagsListView(
                    user: widget.user!,
                    tags: tags,
                    onDeleteCallBack: (databaseTagsForUser) async {
                      await _notesService.deleteTag(
                        user: widget.user!,
                        databaseTagsForUser: databaseTagsForUser,
                      );
                    },
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
      ),
    );
  }
}
