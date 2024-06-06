// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:date_time/date_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
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
import 'package:mynotes_x/utilities/exception_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class CreateUpdateNewNote extends StatefulWidget {
  final DatabaseUser? user;
  final DatabaseNotes? note;
  const CreateUpdateNewNote({
    super.key,
    this.user,
    this.note,
  });

  @override
  State<CreateUpdateNewNote> createState() => _CreateUpdateNewNoteState();
}

class _CreateUpdateNewNoteState extends State<CreateUpdateNewNote> {
  DatabaseNotes? _notes;
  final RxString _imagePath = ''.obs;
  final RxInt _colorValue = 4278190080.obs;
  bool _isList = false;
  final RxBool _setRemainder = false.obs;
  final RxBool _hasTag = false.obs;
  bool _isSetRemainder = false;
  final RxString _time = ''.obs, _date = ''.obs;
  final RxString _repeat = ''.obs;
  late final ListNotifier listNotifier;
  late VoidCallback _listener;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;
  late final TextEditingController _tittleEditingController;
  late final TextEditingController _tagTextEditingController;

  TimeOfDay? _timeOfDay;
  DateTime? _dateTime;

  final List<Map> _categories = [];
  final List<Map> _tagSuggestions = [];
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
  List<DatabaseTagsForUser> _userTags = [];
  final RxList<Map> _foundTags = [{}].obs;

  Future<void> _initView() async {
    final updatingNote = widget.note;
    try {
      _userTags =
          (await _notesService.getTagsForSpecificUser(user: widget.user!))
              .toList();
      for (final i in _userTags) {
        _tagSuggestions.add({
          tagTag: i.tagName,
          checkedTag: false.obs,
        });
      }
    } on NoTagsAvailableForUserException {
      return;
    }

    if (updatingNote != null) {
      try {
        if (updatingNote.imagePath != '') {
          _imagePath.value = updatingNote.imagePath;
          dev.log('image path: ${_imagePath.value}');
        }
        dev.log(
            'date: ${updatingNote.date} ${updatingNote.time} ${updatingNote.repeatStatus}');
        if (updatingNote.date != '' &&
            updatingNote.time != '' &&
            updatingNote.repeatStatus != '') {
          _dateTime = DateTime.parse(updatingNote.date);
          _timeOfDay = TimeOfDay.fromDateTime(_dateTime!);
          _date.value = updatingNote.date;
          _time.value = updatingNote.time;
          _repeat.value = updatingNote.repeatStatus;
          _setRemainder.value = true;
          _isSetRemainder = true;

          dev.log('${_dateTime.toString()} \n ${_timeOfDay.toString()} ');
        }
        _colorValue.value = updatingNote.textColor;
        final tagsList = await _notesService.getTagsForSpecificNote(
          user: widget.user!,
          note: updatingNote,
        );
        final tags = tagsList.toList();
        for (final tag in tags) {
          final item = {
            tagTag: tag.tagName,
            checkedTag: true.obs,
          };
          _tagSuggestions.removeWhere(
              (element) => (element[tagTag] as String) == tag.tagName);
          _tagSuggestions.add(item);
          listNotifier.addItem(item);
        }
        _hasTag.value = true;
      } on CouldNotFindTagsException {
        //do nothing
      }
    }

    _foundTags.value = _tagSuggestions;
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
      imagePath: _imagePath.value,
      textColor: _colorValue.value,
      time: _time.value,
      date: _date.value,
      repeatStatus: _repeat.value,
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

  Future<DatabaseNotes> _createOrGetExistingNote() async {
    final updatingNote = widget.note;
    if (updatingNote != null) {
      _notes = updatingNote;

      _tittleEditingController.text = updatingNote.tittle;
      _textEditingController.text = updatingNote.text;

      return updatingNote;
    }
    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    final userEmail = AuthService.firebase().currentUser!.email!;
    final user = await _notesService.getUser(email: userEmail);
    final newNote = await _notesService.createNote(user: user);
    _notes = newNote;
    return newNote;
  }

  void _deleteIfTextIsEmpty() async {
    final note = _notes;
    final tittle = _tittleEditingController.text;
    final text = _textEditingController.text;
    if (_categories.isEmpty) {
      if (text.isEmpty && tittle.isEmpty && note != null) {
        dev.log('entered delete: ${note.text} ${note.noteID}');
        await _notesService.deleteNote(
          id: note.noteID,
        );
      }
    } else {}
  }

  void _saveIfTextExists() async {
    final note = _notes;
    final tittle = _tittleEditingController.text;
    final text = _textEditingController.text;
    if ((text.isNotEmpty || tittle.isNotEmpty) && note != null) {
      dev.log('from save exists : $_imagePath \n date: $_date');
      await _notesService.updateNote(
        noteToBeUpdated: note,
        tittle: tittle,
        text: text,
        imagePath: _imagePath.value,
        textColor: _colorValue.value,
        time: _time.value,
        date: _date.value,
        repeatStatus: _repeat.value,
      );
    }
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
      _imagePath.value = imagePath.toString();
    } on CouldNotPickImageException {
      return;
    } on CouldNotCaptureImageException {
      return;
    } on PlatformException catch (e) {
      await showExceptionDialog(
        title: 'An Error Occured',
        content: e.code,
        context: context,
      );
    } catch (e) {
      await showExceptionDialog(
        title: 'unknown error occured',
        content: e.toString(),
        context: context,
      );
    }
  }

  Future<void> _deletePhoto() async {
    setState(() {
      imageCache.clear();
      _imagePath.value = '';
    });
  }

  Future<void> _colorPicker(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(
            'Pick a color',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          content: BlockPicker(
            pickerColor: Color(_colorValue.value),
            onColorChanged: (color) {
              setState(() {
                _colorValue.value = color.value;
              });
              dev.log(_colorValue.toString());
            },
          ),
          actions: <Widget>[
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filter(String value) {
    if (value.isEmpty) {
      _foundTags.value = _tagSuggestions;
      return;
    }
    _foundTags.value = _tagSuggestions
        .where((element) => (element[tagTag] as String).contains(value))
        .toList();
  }

  void _reminderPicker() async {
    dev.log('$_date $_time $_repeat');
    dev.log(_dateTime.toString());
    if (!_isSetRemainder) {
      _repeat.value = notificationNoRepeat;
      _time.value = _timeOfDay!.format(context).toString();
      _date.value = _dateTime.toString();
      _isSetRemainder = true;
      dev.log('$_date $_time $_repeat');
    }
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
                    _setRemainder.value = true;
                    setState(() {
                      _dateTime = DateTime.now();
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _date.value = _dateTime.toString();
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
                    _setRemainder.value = true;
                    setState(() {
                      _dateTime = DateTime.now();
                      _dateTime = _dateTime!.add(
                        const Duration(
                          days: 1,
                        ),
                      );
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _date.value = _dateTime.toString();
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
                    _setRemainder.value = true;
                    setState(() {
                      _dateTime = DateTime.now();
                      _dateTime = _dateTime!.add(
                        const Duration(
                          days: 7,
                        ),
                      );
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _date.value = _dateTime.toString();
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
            _dateTime = _dateTime!
                .copyWith(hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
            _time.value = _timeOfDay!.format(context).toString();
            _date.value = _dateTime!.toString();
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
        _setRemainder.value = true;
        setState(() {
          _dateTime = value!;
          _dateTime = _dateTime!
              .copyWith(hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
          _date.value = _dateTime!.toString();
        });
      } catch (e) {
        //do nothing
      }
    });
  }

  void _onTimeTap() {
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
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _time.value = _timeOfDay!.format(context).toString();
                      _date.value = _dateTime.toString();
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
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _time.value = _timeOfDay!.format(context).toString();
                      _date.value = _dateTime.toString();
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
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _time.value = _timeOfDay!.format(context).toString();
                      _date.value = _dateTime.toString();
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
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _time.value = _timeOfDay!.format(context).toString();
                      _date.value = _dateTime.toString();
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
                      _dateTime = _dateTime!.copyWith(
                          hour: _timeOfDay!.hour, minute: _timeOfDay!.minute);
                      _time.value = _timeOfDay!.format(context).toString();
                      _date.value = _dateTime.toString();
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

  void _onDateTap() {
    _reminderPicker();
  }

  void _onRepeatTap() {
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
                      _repeat.value = notificationNoRepeat;
                      for (var week in _weeks) {
                        week[checkedTag] = false;
                      }
                    });
                    Navigator.of(context).pop();
                  }),
              AlterDialogContentButton(
                buttonText: notificationRepeatDaily,
                onPressed: () {
                  setState(() {
                    _repeat.value = notificationRepeatDaily;
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
                    _repeat.value = notificationRepeatWeekly;
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
    super.initState();
    _textEditingController = TextEditingController();
    _tittleEditingController = TextEditingController();
    _tagTextEditingController = TextEditingController();
    _notesService = NotesService();
    _timeOfDay = TimeOfDay.now();
    _dateTime = DateTime.now();

    listNotifier = Provider.of<ListNotifier>(context, listen: false);
    _listener = () {
      setState(() {});
    };
    listNotifier.addListener(_listener);
    _initView();
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
    _tagSuggestions.clear();
    _foundTags.clear();
    _userTags.clear();
    dev.log('dispose');
    dev.log(_date.value);
    dev.log(_imagePath.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _createOrGetExistingNote(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.done:
            if (snapshot.hasData) {
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
                      await _colorPicker(context);
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
                          if (listNotifier.items.isEmpty) {
                            _hasTag.value = false;
                          }
                          dev.log(_hasTag.value.toString());
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
                                    onChanged: (value) => _filter(value),
                                    decoration: InputDecoration(
                                      hintText: 'Add tag',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Obx(
                                    () => Column(
                                      children: _foundTags.asMap().entries.map(
                                        (e) {
                                          final value = e.value;
                                          return TextWithCheckBox(
                                            value: value,
                                            textLeftPadding: 0,
                                            icon: true,
                                            isMainIndexController: false,
                                            index: tagTag,
                                            secondaryIndex: checkedTag,
                                            checkValue:
                                                (value[checkedTag] as RxBool)
                                                    .value,
                                            onChanged: (p0) async {
                                              (value[checkedTag]
                                                      as RxBool) //try to check if this works with normal bool because the _foundTags list is already a rxlist
                                                  .value = !(value[checkedTag]
                                                      as RxBool)
                                                  .value;
                                              if ((value[checkedTag] as RxBool)
                                                      .value ==
                                                  true) {
                                                _hasTag.value = true;
                                                listNotifier.addItem(value);
                                              } else {
                                                listNotifier.removeItem(value);
                                                if (widget.note != null) {
                                                  try {
                                                    await _notesService
                                                        .deleteTagFromSpecificNote(
                                                      user: widget.user!,
                                                      notes: widget.note!,
                                                      tagName: value[tagTag]
                                                          as String,
                                                    );
                                                  } on CouldNotDeleteTagFromSpecificNoteException {
                                                    //do nothing
                                                  }
                                                }
                                              }
                                              dev.log(
                                                  '${listNotifier.items.toString()} \n ${listNotifier.items.length}');
                                            },
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          if (_tagTextEditingController
                                              .text.isNotEmpty) {
                                            try {
                                              await _notesService.saveUserTag(
                                                user: widget.user!,
                                                tagName:
                                                    _tagTextEditingController
                                                        .text,
                                              );
                                              final item = {
                                                checkedTag: true.obs,
                                                tagTag:
                                                    _tagTextEditingController
                                                        .text,
                                              };
                                              _tagSuggestions.add(item);
                                              _foundTags.value =
                                                  _tagSuggestions;
                                              listNotifier.addItem(item);
                                              dev.log(listNotifier.items
                                                  .toString());
                                            } on TagAlreadyExistsException {
                                              //do nothing
                                            }
                                            _tagTextEditingController.clear();
                                          }
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
                  try {
                    if (_isList) {
                      dev.log('IS LIST!!!!!!!');
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
                    if (_setRemainder.value) {
                      dev.log('IS REMAAINDER!!!!!!!');
                      if (_repeat.value == notificationNoRepeat) {
                        await NotificationService.getInstance()
                            .showNotification(
                          id: 0,
                          title: _tittleEditingController.text,
                          payload: 'payload',
                          body: DateFormat('EEEE, d MMM, yyyy')
                              .format(_dateTime!),
                          scheduledDate: _dateTime!,
                        );
                      } else if (_repeat.value == notificationRepeatDaily) {
                        await NotificationService.getInstance()
                            .showNotificationDaily(
                          id: 0,
                          title: _tittleEditingController.text,
                          payload: 'payload',
                          body: DateFormat('EEEE, d MMM, yyyy')
                              .format(_dateTime!),
                          scheduledDate: _dateTime!,
                        );
                      } else if (_repeat.value == notificationRepeatWeekly) {
                        List<int> days = [];
                        for (var i in _weeks) {
                          if (i[checkedTag] == true) {
                            if (i[weekTag] == 'monday') {
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
                        if (days.isNotEmpty) {
                          dev.log(days.toString());
                          await NotificationService.getInstance()
                              .showNotificationWeekly(
                            id: 0,
                            title: _tittleEditingController.text,
                            payload: 'payload',
                            body: DateFormat('EEEE, d MMM, yyyy')
                                .format(_dateTime!),
                            scheduledDate: _dateTime!,
                            days: days,
                          );
                        } else {
                          throw const UnselectedWeekExceptioon();
                        }
                      }
                    }
                    if (_hasTag.value && listNotifier.items.isNotEmpty) {
                      dev.log('IS HASH TAG!!!!!!!');
                      for (final i in _foundTags) {
                        final check = i[checkedTag] as RxBool;
                        if (check.value == true) {
                          try {
                            final test = await _notesService.createTag(
                              user: widget.user!,
                              note: _notes!,
                              tagName: (i[tagTag] as String),
                              isCheckedForSpecificTag: check.value,
                            );
                            dev.log('test: ${test.toString()}');
                          } on TagExistsForSpecificNote {
                            //do nothing
                          }
                        }
                      }
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } on UnselectedWeekExceptioon catch (e) {
                    await showExceptionDialog(
                      title: e.code,
                      content:
                          'you haven\'t selected any week. please select one to continue or change the repeat status.',
                      context: context,
                    );
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Obx(
                          () => (_imagePath.value.isNotEmpty
                              ? Stack(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  children: [
                                    Image.file(
                                      File(_imagePath.value),
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
                        Obx(
                          () => MyTextField(
                            maxLines: 1,
                            controller: _tittleEditingController,
                            autoCorrect: false,
                            enableSuggestions: true,
                            obscureText: false,
                            hintText: 'Tittle',
                            horizontalPadding: 10,
                            verticalPadding: 0,
                            textInputStyle: TextStyle(
                              color: Color(_colorValue.value),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        (!_isList
                            ? Obx(
                                () => MyTextField(
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
                                    color: Color(_colorValue.value),
                                  ),
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
                              Obx(
                                () => (_setRemainder.value
                                    ? RemainderWidget(
                                        date: _dateTime,
                                        time: _timeOfDay,
                                        repeat: _repeat.value,
                                        onDateTap: _onDateTap,
                                        onExit: () {
                                          _repeat.value = '';
                                          _time.value = '';
                                          _date.value = '';
                                          _setRemainder.value = false;
                                          setState(() {
                                            _timeOfDay = TimeOfDay.now();
                                            _dateTime = DateTime.now();
                                            for (var week in _weeks) {
                                              week['isChecked'] = false;
                                            }
                                            _isSetRemainder = false;
                                          });
                                        },
                                        onRepeatTap: _onRepeatTap,
                                        onTimeTap: _onTimeTap,
                                      )
                                    : Text(
                                        'No Remainder'.obs.value,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      )),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
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
                                child: (listNotifier.items.isNotEmpty
                                    ? Wrap(
                                        spacing: 0,
                                        runSpacing: 0,
                                        direction: Axis.horizontal,
                                        children: listNotifier.items
                                            .map(
                                              (tags) => ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 150,
                                                  maxHeight: 26,
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
                                                    tags[tagTag] as String,
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
                          height: 20,
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

class UnselectedWeekExceptioon implements Exception {
  final code = 'select a week';
  const UnselectedWeekExceptioon();
}
