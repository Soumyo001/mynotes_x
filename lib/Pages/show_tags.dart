import 'package:flutter/material.dart';
import 'package:mynotes_x/components/tag_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

enum TagOptions { edit, delete }

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
              List<DatabaseTagsForUser> tags = [];
              if (snapshot.hasData) {
                tags = snapshot.data as List<DatabaseTagsForUser>;
              }
              print(tags);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return TagTile(
                        title: tag.tagName,
                        trailing: PopupMenuButton<TagOptions>(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onSelected: (value) async {
                            switch (value) {
                              case TagOptions.edit:
                                break;
                              case TagOptions.delete:
                                print('object');
                                break;
                              default:
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<TagOptions>(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                value: TagOptions.edit,
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuItem<TagOptions>(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                value: TagOptions.delete,
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
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
