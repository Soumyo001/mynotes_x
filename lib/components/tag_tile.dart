import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/utilities/dialogs/delete_dialog.dart';

enum TagOptions { edit, delete }

class TagTile extends StatefulWidget {
  final DatabaseTagsForUser userTag;
  final void Function() delete;
  final DatabaseUser user;

  const TagTile({
    super.key,
    required this.userTag,
    required this.delete,
    required this.user,
  });

  @override
  State<TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  bool _isEditable = false;
  late final TextEditingController _textEditingController;
  late final NotesService _notesService;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _notesService = NotesService();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
        left: 25,
        right: 25,
      ),
      child: ListTile(
        title: _isEditable
            ? CupertinoTextField(
                controller: _textEditingController,
                cursorColor: Theme.of(context).colorScheme.inversePrimary,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              )
            : Text(
                widget.userTag.tagName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
        trailing: !_isEditable
            ? PopupMenuButton<TagOptions>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (value) async {
                  switch (value) {
                    case TagOptions.edit:
                      setState(() {
                        _textEditingController.text = widget.userTag.tagName;
                        _isEditable = true;
                      });
                      break;
                    case TagOptions.delete:
                      final shouldDelete =
                          await showDeleteDialog(context: context);
                      if (shouldDelete) {
                        widget.delete();
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
              )
            : IconButton(
                onPressed: () async {
                  await _notesService.updateTag(
                    databaseTags: widget.userTag,
                    user: widget.user,
                    tagName: _textEditingController.text,
                  );
                  setState(() {
                    _isEditable = false;
                    _textEditingController.clear();
                  });
                },
                icon: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
      ),
    );
  }
}
