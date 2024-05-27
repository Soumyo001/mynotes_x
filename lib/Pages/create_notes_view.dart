import 'dart:io';
import 'package:date_time/date_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mynotes_x/components/alert_dialog_content_button.dart';
import 'package:mynotes_x/components/input_check_box.dart';
import 'package:mynotes_x/components/my_text_field.dart';
import 'package:mynotes_x/components/remainder_widget.dart';
import 'package:mynotes_x/components/text_with_checkbox_from_list.dart';
import 'package:mynotes_x/notifiers/list_notifier.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/crud/crud_exceptions.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/services/notification_services/notification_service.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class CreateNewNote extends StatefulWidget {
  const CreateNewNote({super.key});

  @override
  State<CreateNewNote> createState() => _CreateNewNoteState();
}

class _CreateNewNoteState extends State<CreateNewNote> {
  DatabaseNotes? _notes;
  DatabaseUser? _user;
  File? _image;
  String? _imagePath = '';
  Color? _color;
  bool _isList = false;
  bool _setRemainder = false;
  bool _hasTag = false;
  String? month, week;
  String? repeat;
  late final ListNotifier listNotifier;
  late VoidCallback _listener;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;
  late final TextEditingController _tittleEditingController;
  late final TextEditingController _tagTextEditingController;

  TimeOfDay? _timeOfDay;
  DateTime? _dateTime;

  final List<Map> _categories = [];
  final List<Map> _tagSuggestions = [
    {
      checkedTag: false,
      tagTag: 'inspiration',
    },
    {
      checkedTag: false,
      tagTag: 'work',
    },
    {
      checkedTag: false,
      tagTag: 'piano',
    },
  ];
  final List<Map> _weeks = [
    {
      weekTag: saturday,
      checkedTag: false,
    },
    {
      weekTag: sunday,
      checkedTag: false,
    },
    {
      weekTag: monday,
      checkedTag: false,
    },
    {
      weekTag: tuesday,
      checkedTag: false,
    },
    {
      weekTag: wednesday,
      checkedTag: false,
    },
    {
      weekTag: thursday,
      checkedTag: false,
    },
    {
      weekTag: friday,
      checkedTag: false,
    },
  ];

  List<Map> _foundTags = [];

  Future<bool> _showExceptionDialog({
    required String tittle,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          icon: Icon(
            Icons.info,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          title: Text(
            tittle,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          content: Text(
            content,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            )
          ],
        );
      },
    ).then((value) => value ?? true);
  }

  void _textAndTittleEditingControllerListener() async {
    final note = _notes;
    if (note == null) {
      return;
    }
    final tittle = _tittleEditingController.text;
    final text = _textEditingController.text;
    await _notesService.updateNote(
      noteToBeUpdated: note,
      tittle: tittle,
      text: text,
      imagePath: _imagePath,
    );
  }

  void _setupTextAndTittleEditingControllerListener() async {
    _tittleEditingController.removeListener(
      _textAndTittleEditingControllerListener,
    );
    _textEditingController.removeListener(
      _textAndTittleEditingControllerListener,
    );
    _tittleEditingController.addListener(
      _textAndTittleEditingControllerListener,
    );
    _textEditingController.addListener(
      _textAndTittleEditingControllerListener,
    );
  }

  Future<DatabaseNotes> createNote() async {
    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    final userEmail = AuthService.firebase().currentUser!.email!;
    final user = await _notesService.getUser(email: userEmail);
    return await _notesService.createNote(user: user);
  }

  void _deleteIfTextIsEmpty() async {
    final note = _notes;
    final tittle = _tittleEditingController.text;
    final text = _textEditingController.text;
    if ((text.isEmpty || _categories.isEmpty) &&
        tittle.isEmpty &&
        note != null) {
      await _notesService.deleteNote(
        id: note.noteID,
      );
    }
  }

  void _saveIfTextExists() async {
    final note = _notes;
    final tittle = _tittleEditingController.text;
    final text = _textEditingController.text;
    if ((text.isNotEmpty || tittle.isNotEmpty) && note != null) {
      await _notesService.updateNote(
        noteToBeUpdated: note,
        tittle: tittle,
        text: text,
        imagePath: _imagePath,
      );
    } else if (_categories.isNotEmpty && note != null) {}
  }

  Future<void> _photoPicker(ImageSource source) async {
    try {
      final imagePickerGallery = await ImagePicker().pickImage(
        source: source,
      );
      if (imagePickerGallery == null) {
        if (source == ImageSource.gallery) {
          throw const CouldNotPickImageException();
        } else {
          throw const CouldNotCaptureImageException();
        }
      }
      final imagePath = imagePickerGallery.path;
      _imagePath = imagePath;
      final image = File(imagePath);
      setState(() {
        _image = image;
      });
    } on CouldNotCaptureImageException catch (e) {
      await _showExceptionDialog(
        tittle: 'Couldn\'t capture image',
        content: e.code,
      );
    } on CouldNotPickImageException catch (e) {
      await _showExceptionDialog(
        tittle: 'Couldn\'t load image',
        content: e.code,
      );
    } on PlatformException catch (e) {
      await _showExceptionDialog(
        tittle: 'Couldn\'t pick image',
        content: e.code,
      );
    } catch (e) {
      await _showExceptionDialog(
        tittle: 'unknown error occured',
        content: e.toString(),
      );
    }
  }

  Future<void> _deletePhoto() async {
    if (_imagePath != null) {
      setState(() {
        imageCache.clear();
        _imagePath = '';
        _image = null;
      });
    } else {
      await _showExceptionDialog(
        tittle: 'Pick an image',
        content: 'You didn\'t pick an image',
      );
    }
  }

  Future<bool> colorPicker(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Pick a color',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          content: BlockPicker(
            pickerColor: Colors.red,
            onColorChanged: (color) {
              setState(() {
                _color = color;
              });
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Select',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? true);
  }

  void _filter(String value, void Function(void Function()) setState) {
    if (value.isEmpty) {
      setState(() {
        _foundTags = _tagSuggestions;
      });
      return;
    }
    setState(() {
      _foundTags = _tagSuggestions
          .where((element) =>
              (element[tagTag] as String).toLowerCase().contains(value))
          .toList();
    });
  }

  void _reminderPicker() {
    _setRemainder = true;
    repeat = notificationNoRepeat;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _dateTime = DateTime.now();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _dateTime = DateTime.now();
                      _dateTime = _dateTime!.add(
                        const Duration(
                          days: 1,
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Tomorrow',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _dateTime = DateTime.now();
                      _dateTime = _dateTime!.add(
                        const Duration(
                          days: 7,
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Next Week',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _showDatePicker();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Pick a date...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTimePicker() async {
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      barrierColor: Theme.of(context).colorScheme.inversePrimary,
    ).then(
      (value) {
        try {
          setState(() {
            _timeOfDay = value!;
          });
        } catch (e) {
          //do nothing
        }
      },
    );
  }

  Future<void> _showDatePicker() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2500),
    ).then((value) {
      try {
        setState(() {
          _dateTime = value!;
        });
      } catch (e) {
        //do nothing
      }
    });
  }

  void onTimeTap() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _timeOfDay = const TimeOfDay(hour: 9, minute: 00);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Morning (9:00 AM)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _timeOfDay = const TimeOfDay(hour: 12, minute: 00);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Noon (12:00 PM)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _timeOfDay = const TimeOfDay(hour: 15, minute: 00);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Afternoon (3:00 PM)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _timeOfDay = const TimeOfDay(hour: 18, minute: 00);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Evening (6:00 PM)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _timeOfDay = const TimeOfDay(hour: 21, minute: 00);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Late evening (9:00 PM)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _showTimePicker();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    alignment: Alignment.centerLeft,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Pick a time...',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onDateTap() {
    _reminderPicker();
  }

  void onRepeatTap() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          content: Column(
            children: [
              AlterDialogContentButton(
                  buttonText: notificationNoRepeat,
                  onPressed: () {
                    setState(() {
                      repeat = notificationNoRepeat;
                      for (var week in _weeks) {
                        week['isChecked'] = false;
                      }
                    });
                    Navigator.of(context).pop();
                  }),
              AlterDialogContentButton(
                buttonText: notificationRepeatDaily,
                onPressed: () {
                  setState(() {
                    repeat = notificationRepeatDaily;
                    for (var week in _weeks) {
                      week[checkedTag] = false;
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
              AlterDialogContentButton(
                buttonText: notificationRepeatWeekly,
                onPressed: () {
                  setState(() {
                    repeat = notificationRepeatWeekly;
                  });
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog.adaptive(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _weeks.asMap().entries.map((e) {
                                final value = e.value;
                                return TextWithCheckBox(
                                  value: value,
                                  icon: false,
                                  textLeftPadding: 10,
                                  isMainIndexController: false,
                                  onChanged: (p0) {
                                    setState(() {
                                      value[checkedTag] = p0!;
                                    });
                                  },
                                  index: weekTag,
                                  secondaryIndex: checkedTag,
                                );
                              }).toList(),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                textStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                                child: const Text(
                                  'Done',
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _tittleEditingController = TextEditingController();
    _tagTextEditingController = TextEditingController();
    _notesService = NotesService();
    _foundTags = _tagSuggestions;

    _timeOfDay = TimeOfDay.now();
    _dateTime = DateTime.now();

    listNotifier = Provider.of<ListNotifier>(context, listen: false);
    _listener = () {
      setState(() {});
    };
    listNotifier.addListener(_listener);

    super.initState();
  }

  @override
  void dispose() {
    _deleteIfTextIsEmpty();
    _saveIfTextExists();
    _textEditingController.dispose();
    _tittleEditingController.dispose();
    _tagTextEditingController.dispose();
    listNotifier.removeListener(_listener);
    listNotifier.items.clear();
    _categories.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createNote(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.done:
            if (snapshot.hasData) {
              _notes = snapshot.data as DatabaseNotes;
              _setupTextAndTittleEditingControllerListener();
            }
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                foregroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () async {
                      await colorPicker(context);
                    },
                    icon: Icon(
                      Icons.color_lens,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Add image',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                            actions: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _photoPicker(ImageSource.camera);
                                },
                                icon: Icon(
                                  Icons.camera,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                label: Text(
                                  'Take photo',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _photoPicker(ImageSource.gallery);
                                },
                                icon: Icon(
                                  Icons.photo_rounded,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                label: Text(
                                  'Choose image',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.photo,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              setState(() {
                                _hasTag = true;
                                if (listNotifier.items.isEmpty) {
                                  _hasTag = false;
                                }
                                dev.log(_hasTag.toString());
                              });
                              return AlertDialog.adaptive(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                title: Text(
                                  'Tags',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: _tagTextEditingController,
                                        enableSuggestions: true,
                                        autocorrect: false,
                                        maxLines: 1,
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                        onChanged: (value) =>
                                            _filter(value, setState),
                                        decoration: InputDecoration(
                                          hintText: 'Add tag',
                                          hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Column(
                                        children:
                                            _foundTags.asMap().entries.map(
                                          (e) {
                                            final value = e.value;
                                            return TextWithCheckBox(
                                              value: value,
                                              textLeftPadding: 0,
                                              icon: true,
                                              isMainIndexController: false,
                                              index: tagTag,
                                              secondaryIndex: checkedTag,
                                              onChanged: (p0) {
                                                setState(() {
                                                  value[checkedTag] = p0!;
                                                  if (value[checkedTag] ==
                                                      true) {
                                                    listNotifier.addItem(value);
                                                  } else {
                                                    listNotifier
                                                        .removeUnCheckedItems();
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ).toList(),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Done',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary,
                                              ),
                                            ),
                                            onPressed: () {
                                              if (_tagTextEditingController
                                                  .text.isNotEmpty) {
                                                setState(() {
                                                  _tagSuggestions.add(
                                                    {
                                                      checkedTag: true,
                                                      tagTag:
                                                          _tagTextEditingController
                                                              .text,
                                                    },
                                                  );
                                                  _foundTags = _tagSuggestions;
                                                  listNotifier
                                                      .reload(_foundTags);
                                                  _tagTextEditingController
                                                      .clear();
                                                });
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.local_offer_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isList = !_isList;
                      });
                    },
                    icon: SizedBox(
                      width: 20,
                      height: 20,
                      child: (!_isList
                          ? Image.asset(
                              'lib/images/list.png',
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            )
                          : Image.asset(
                              'lib/images/cross.png',
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            )),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: () async {
                  _dateTime = _dateTime!.copyWith(
                      hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                  _user = await _notesService.getUser(
                    email: AuthService.firebase().currentUser!.email!,
                  );
                  if (_isList) {
                    String text = '';
                    for (var i in _categories) {
                      if ((i[controllerTag] as TextEditingController)
                          .text
                          .isNotEmpty) {
                        text +=
                            (i[controllerTag] as TextEditingController).text;
                        text += ' ';
                        text += (i[checkedTag] as bool).toString();
                        text += '\n';
                      } else {
                        break;
                      }
                    }
                    dev.log(text);
                  }
                  if (_hasTag) {
                    for (final i in _foundTags) {
                      if ((i[checkedTag] as bool) == true) {
                        try {
                          final test = await _notesService.createTag(
                            user: _user!,
                            note: _notes!,
                            tagName: (i[tagTag] as String),
                          );
                          dev.log('test: ${test.toString()}');
                        } on TagExistsForSpecificNote {
                          //do nothing
                        }
                      }
                    }
                    final e = await _notesService.getTagsForSpecificNote(
                        user: _user!, notes: _notes!);
                    dev.log(e.toList().toString());
                  }
                  if (_setRemainder) {
                    if (repeat == notificationNoRepeat) {
                      await NotificationService.getInstance().showNotification(
                        id: 0,
                        title: _tittleEditingController.text,
                        body: DateFormat('EEEE', 'en_US').format(_dateTime!),
                        scheduledDate: _dateTime!,
                      );
                    } else if (repeat == notificationRepeatDaily) {
                      await NotificationService.getInstance()
                          .showNotificationDaily(
                        id: 0,
                        payload: 'payload here',
                        title: _tittleEditingController.text,
                        body: DateFormat('EEEE', 'en_US').format(_dateTime!),
                        scheduledDate: _dateTime!,
                      );
                    } else if (repeat == notificationRepeatWeekly) {
                      List<int> days = [];
                      for (var i in _weeks) {
                        if (i['isChecked'] == true) {
                          if (i['week'] == 'monday') {
                            days.add(DateTime.monday);
                          } else if (i[weekTag] == tuesday) {
                            days.add(DateTime.tuesday);
                          } else if (i[weekTag] == wednesday) {
                            days.add(DateTime.wednesday);
                          } else if (i[weekTag] == thursday) {
                            days.add(DateTime.thursday);
                          } else if (i[weekTag] == friday) {
                            days.add(DateTime.friday);
                          } else if (i[weekTag] == saturday) {
                            days.add(DateTime.saturday);
                          } else if (i[weekTag] == sunday) {
                            days.add(DateTime.sunday);
                          }
                        }
                      }
                      await NotificationService.getInstance()
                          .showNotificationWeekly(
                        id: 0,
                        title: _tittleEditingController.text,
                        body: DateFormat('EEEE', 'en_US').format(_dateTime!),
                        scheduledDate: _dateTime!,
                        days: days,
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          child: (_image != null
                              ? Stack(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  children: [
                                    Image.file(
                                      _image!,
                                      width: 345,
                                      height: 330,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await _deletePhoto();
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 15,
                                )),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          maxLines: 1,
                          controller: _tittleEditingController,
                          autoCorrect: false,
                          enableSuggestions: true,
                          obscureText: false,
                          hintText: 'Tittle',
                          horizontalPadding: 10,
                          verticalPadding: 0,
                          textInputStyle: TextStyle(
                            color: _color,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        (!_isList
                            ? MyTextField(
                                controller: _textEditingController,
                                autoCorrect: false,
                                keyboardType: TextInputType.multiline,
                                enableSuggestions: true,
                                obscureText: false,
                                hintText: 'Type your notes here...',
                                horizontalPadding: 10,
                                verticalPadding: 0,
                                maxLines: null,
                                textInputStyle: TextStyle(
                                  color: _color,
                                ),
                              )
                            : Column(
                                children: [
                                  Column(
                                    children: _categories.asMap().entries.map(
                                      (e) {
                                        int index = e.key;
                                        final value = e.value;
                                        if (value[checkedTag] == false) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: TextFieldCheckBox(
                                              favourite: value,
                                              onPressed: () {
                                                setState(() {
                                                  (_categories[index]
                                                              [controllerTag]
                                                          as TextEditingController)
                                                      .dispose();
                                                  _categories.removeAt(index);
                                                });
                                              },
                                              onChanged: (p0) {
                                                setState(() {
                                                  value[checkedTag] = p0!;
                                                  if (value[checkedTag] ==
                                                      true) {
                                                    if ((value[controllerTag]
                                                            as TextEditingController)
                                                        .text
                                                        .isEmpty) {
                                                      _categories
                                                          .removeAt(index);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ).toList(),
                                  ),
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _categories.add(
                                          {
                                            checkedTag: false,
                                            controllerTag:
                                                TextEditingController(),
                                          },
                                        );
                                      });
                                    },
                                    child: Text(
                                      '+ Add item',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: _categories.asMap().entries.map(
                                      (e) {
                                        final value = e.value;
                                        if (value[checkedTag] == true) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: TextWithCheckBox(
                                              value: value,
                                              textLeftPadding: 20,
                                              onChanged: (p0) {
                                                setState(() {
                                                  value[checkedTag] = p0!;
                                                });
                                              },
                                              index: controllerTag,
                                              secondaryIndex: checkedTag,
                                              isMainIndexController: true,
                                              icon: false,
                                              textDecoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 14.3,
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ).toList(),
                                  ),
                                ],
                              )),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Divider(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _reminderPicker,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.alarm_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              (_setRemainder
                                  ? RemainderWidget(
                                      date: _dateTime,
                                      time: _timeOfDay,
                                      repeat: repeat!,
                                      onDateTap: onDateTap,
                                      onExit: () {
                                        setState(() {
                                          repeat = null;
                                          _timeOfDay = TimeOfDay.now();
                                          _dateTime = DateTime.now();
                                          for (var week in _weeks) {
                                            week['isChecked'] = false;
                                          }
                                          _setRemainder = false;
                                        });
                                      },
                                      onRepeatTap: () => onRepeatTap(),
                                      onTimeTap: onTimeTap,
                                    )
                                  : Text(
                                      'No Remainder',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ],
                              ),
                              Flexible(
                                child: (listNotifier.items.isNotEmpty && _hasTag
                                    ? Wrap(
                                        spacing: 0,
                                        runSpacing: 0,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        children: listNotifier.items
                                            .map(
                                              (tags) => ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 150,
                                                  maxHeight: 25,
                                                ),
                                                child: Chip(
                                                  labelPadding: EdgeInsets.zero,
                                                  side: BorderSide.none,
                                                  avatar: Icon(
                                                    Icons.tag,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                  label: Text(
                                                    tags['tag'] as String,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary
                                                          .withOpacity(0.8),
                                                    ),
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : const SizedBox.shrink()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}

class CouldNotPickImageException implements Exception {
  final code = 'could not load image';
  const CouldNotPickImageException();
}

class CouldNotCaptureImageException implements Exception {
  final code = 'could not capture image';
  const CouldNotCaptureImageException();
}
