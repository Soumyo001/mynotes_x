import 'package:flutter/material.dart';
import 'package:mynotes_x/components/tag_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/delete_dialog.dart';

enum TagOptions { edit, delete }

typedef TagDeleteCallBack = void Function(
    DatabaseTagsForUser databaseTagsForUser);

class TagsListView extends StatelessWidget {
  final List<DatabaseTagsForUser> tags;
  final TagDeleteCallBack onDeleteCallback;
  const TagsListView({
    super.key,
    required this.tags,
    required this.onDeleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return TagTile(
          title: tag.tagName,
          trailing: PopupMenuButton<TagOptions>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) async {
              switch (value) {
                case TagOptions.edit:
                  break;
                case TagOptions.delete:
                  final shouldDelete = await showDeleteDialog(context: context);
                  if (shouldDelete) {
                    onDeleteCallback(tag);
                  }
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<TagOptions>(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  value: TagOptions.edit,
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuItem<TagOptions>(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  value: TagOptions.delete,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ];
            },
          ),
        );
      },
    );
  }
}
