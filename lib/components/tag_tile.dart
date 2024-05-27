import 'package:flutter/material.dart';

class TagTile extends StatefulWidget {
  final String title;
  final Widget? trailing;
  const TagTile({
    super.key,
    required this.title,
    required this.trailing,
  });

  @override
  State<TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
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
        title: Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        trailing: widget.trailing,
      ),
    );
  }
}
