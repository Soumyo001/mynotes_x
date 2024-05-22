import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RemainderWidget extends StatefulWidget {
  final DateTime? date;
  final String? isTodayOrTomorrow;
  final TimeOfDay? time;
  final void Function()? onDateTap, onTimeTap, onRepeatTap, onExit;
  final String repeat;
  const RemainderWidget({
    super.key,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onRepeatTap,
    required this.onExit,
    required this.time,
    required this.date,
    required this.repeat,
    this.isTodayOrTomorrow,
  });

  @override
  State<RemainderWidget> createState() => _RemainderWidgetState();
}

class _RemainderWidgetState extends State<RemainderWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onDateTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            (widget.date != null
                                ? DateFormat('EEE, d MMM, yyyy')
                                    .format(widget.date!)
                                : '${widget.isTodayOrTomorrow}'),
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: widget.onRepeatTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.repeat,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onTimeTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            (widget.time != null
                                ? widget.time!.format(context).toString()
                                : '12:00 PM'),
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: widget.onExit,
                icon: Icon(
                  Icons.highlight_remove_rounded,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
