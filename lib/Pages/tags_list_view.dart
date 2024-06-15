import 'package:flutter/material.dart';
import 'package:mynotes_x/components/tag_tile.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';

typedef TagCallBack = void Function(DatabaseTagsForUser databaseTagsForUser);

class TagsListView extends StatefulWidget {
  final List<DatabaseTagsForUser> tags;
  final DatabaseUser user;
  final TagCallBack onDeleteCallBack;
  const TagsListView({
    super.key,
    required this.tags,
    required this.onDeleteCallBack,
    required this.user,
  });

  @override
  State<TagsListView> createState() => _TagsListViewState();
}

class _TagsListViewState extends State<TagsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tags.length,
      itemBuilder: (context, index) {
        final tag = widget.tags[index];
        return TagTile(
          user: widget.user,
          userTag: tag,
          delete: () {
            widget.onDeleteCallBack(tag);
          },
        );
      },
    );
  }
}
