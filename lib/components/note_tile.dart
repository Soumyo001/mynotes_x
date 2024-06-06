import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:popover/popover.dart';

class NoteTile extends StatefulWidget {
  final int index;
  final DatabaseNotes note;
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;
  const NoteTile({
    super.key,
    required this.index,
    required this.note,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool isGridPressed = false;

  void _showMenu() {
    showPopover(
      backgroundColor: Theme.of(context).colorScheme.primary,
      context: context,
      direction: PopoverDirection.bottom,
      width: 150,
      height: 100,
      arrowHeight: 10,
      arrowWidth: 20,
      bodyBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              InkWell(
                onTap: widget.onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                  width: double.infinity,
                  child: const Center(child: Text('Edit')),
                ),
              ),
              InkWell(
                onTap: widget.onDeleteTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('Delete')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showMenu();
      },
      onLongPressDown: (details) {
        setState(() {
          if (!isGridPressed) {
            isGridPressed = true;
          }
        });
      },
      onLongPressUp: () {
        setState(() {
          if (isGridPressed) {
            isGridPressed = false;
          }
        });
      },
      onLongPressCancel: () {
        setState(() {
          isGridPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 95,
        ),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isGridPressed
                ? Theme.of(context).colorScheme.shadow.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary),
          ),
          boxShadow: (isGridPressed
              ? []
              : [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.09),
                    spreadRadius: 1.0,
                    blurRadius: 15.0,
                    offset: const Offset(-6.0, -6.0),
                  ),
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.8),
                    spreadRadius: 1.0,
                    blurRadius: 15.0,
                    offset: const Offset(6.0, 6.0),
                  ),
                ]),
        ),
        child: ListTile(
          horizontalTitleGap: 7,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3,
          ),
          leading: Text(
            (widget.index + 1).toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 17,
            ),
          ),
          title: Text(
            widget.note.tittle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            widget.note.text,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 13,
            ),
          ),
        ),
      ).animate().scaleXY(
            begin: 1.5,
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeIn,
          ),
    );
  }
}
