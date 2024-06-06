import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynotes_x/services/crud/crud_exceptions.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as dev;

class NotesService {
  Database? _db;
  List<DatabaseNotes> _notes = [];
  List<DatabaseTagsForUser> _tags = [];

  late final StreamController<List<DatabaseNotes>> _noteStreamController;

  late final StreamController<List<DatabaseTagsForUser>> _tagStreamController;

  Stream<List<DatabaseNotes>> get allNotes => _noteStreamController.stream;
  Stream<List<DatabaseTagsForUser>> get allTags => _tagStreamController.stream;

  NotesService._sharedObject() {
    _noteStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _noteStreamController.sink.add(_notes);
      },
    );
    _tagStreamController =
        StreamController<List<DatabaseTagsForUser>>.broadcast(
      onListen: () {
        _tagStreamController.sink.add(_tags);
      },
    );
  }
  static final NotesService _shared = NotesService._sharedObject();
  factory NotesService() => _shared;

  Future<void> _ensureDbIsOpened() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    dev.log('get or create user called: $email');
    try {
      final user = await getUser(email: email);
      await _createDefaultTags(user);
      await _cacheAllNotes(user.userID);
      await _cacheAllTags(user.userID);
      dev.log('get user called');
      return user;
    } on UserDoesNotExistsException {
      final createdUser = await createUser(email: email);
      await _createDefaultTags(createdUser);
      await _cacheAllNotes(createdUser.userID);
      await _cacheAllTags(createdUser.userID);
      dev.log(' create user called');
      return createdUser;
    } catch (e) {
      dev.log('exception : ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _createDefaultTags(DatabaseUser user) async {
    dev.log('entered create default tag');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dev.log('set bool ');
    bool defaultTagsInserted = prefs.getBool('defaultTagsInserted') ?? false;
    dev.log(defaultTagsInserted.toString());
    if (!defaultTagsInserted) {
      try {
        await NotesService().saveUserTag(user: user, tagName: 'inspiration');
        await NotesService().saveUserTag(user: user, tagName: 'work');
        await NotesService().saveUserTag(user: user, tagName: 'piano');
      } on TagAlreadyExistsException {
        //do nothing
      }
      prefs.setBool('defaultTagsInserted', true);
    }
  }

  Future<void> _cacheAllNotes(int userId) async {
    try {
      _notes.clear();
      final allNotes = await getAllNote(userId);
      _notes = allNotes.toList();
      _noteStreamController.add(_notes);
    } on CouldNotFindNoteException {
      //do nothing
      dev.log('Exception on cache all notes');
    }
  }

  Future<void> _cacheAllTags(int userId) async {
    try {
      _tags.clear();
      final allTags = await getAllTags(userId);
      _tags = allTags.toList();
      _tagStreamController.add(_tags);
      dev.log('_tags cached : ${_tags.toString()}');
    } on CouldNotFindTagsException {
      dev.log('Exception on cache all tags');
      //do nothing
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenedException();
    }
    return db;
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final documentPath = await getApplicationDocumentsDirectory();
      final designatedPath = join(documentPath.path, dbName);
      final db = await openDatabase(designatedPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNotesTable);
      await db.execute(createTagsTable);
      await db.execute(createUserTagsTable);
      await db.execute(createRemainderTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenedException();
    }
    await db.close();
    _db = null;
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userID = await db.insert(
      userTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );
    return DatabaseUser(
      userID: userID,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );
    if (result.isEmpty) {
      throw UserDoesNotExistsException();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser user}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final userFromDB = await getUser(
      email: user.email,
    );
    if (userFromDB != user) {
      throw UserDoesNotExistsException();
    }
    const tittle = '';
    const text = '';
    const imagePath = '';
    const textColor = 4278190080;
    const time = '';
    const date = '';
    const repeatStatus = '';
    final noteID = await db.insert(
      notesTable,
      {
        userIdColumn: user.userID,
        noteTittleColumn: tittle,
        noteTextColumn: text,
        noteImagePathColumn: imagePath,
        noteTextColorColumn: textColor,
        remainderDateColumn: date,
        remainderTimeColumn: time,
        remainderRepeatStatusColumn: repeatStatus,
      },
    );
    final note = DatabaseNotes(
      noteID: noteID,
      userID: user.userID,
      tittle: tittle,
      text: text,
      imagePath: imagePath,
      textColor: textColor,
      date: date,
      time: time,
      repeatStatus: repeatStatus,
    );
    _notes.add(note);
    _noteStreamController.add(_notes);
    return note;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      notesTable,
      limit: 1,
      where: 'note_id = ?',
      whereArgs: [
        id,
      ],
    );
    if (result.isEmpty) {
      throw CouldNotFindNoteException();
    }
    final note = DatabaseNotes.fromRow(result.first);
    _notes.removeWhere((note) => note.noteID == id);
    _notes.add(note);
    _noteStreamController.add(_notes);
    return note;
  }

  Future<Iterable<DatabaseNotes>> getAllNote(int userId) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    }

    return results.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'note_id = ?',
      whereArgs: [
        id,
      ],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNoteException();
    }
    _notes.removeWhere((note) => note.noteID == id);
    _noteStreamController.add(_notes);
  }

  Future<int> deleteAllNote() async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final count = await db.delete(notesTable);
    _notes.clear();
    _noteStreamController.add(_notes);
    return count;
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes noteToBeUpdated,
    required String? tittle,
    required String? text,
    required int textColor,
    required String? imagePath,
    required String time,
    required String date,
    required String repeatStatus,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    await getNote(
      id: noteToBeUpdated.noteID,
    );
    final updateCount = await db.update(
      notesTable,
      {
        noteTittleColumn: tittle,
        noteTextColumn: text,
        noteImagePathColumn: imagePath!,
        noteTextColorColumn: textColor,
        remainderDateColumn: date,
        remainderTimeColumn: time,
        remainderRepeatStatusColumn: repeatStatus,
      },
      where: 'note_id = ?',
      whereArgs: [
        noteToBeUpdated.noteID,
      ],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNotesException();
    }
    final updatedNote = await getNote(id: noteToBeUpdated.noteID);
    _notes.removeWhere(
      (databaseNote) => databaseNote.noteID == updatedNote.noteID,
    );
    _notes.add(updatedNote);
    _noteStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseTagsForUser> saveUserTag({
    required DatabaseUser user,
    required String tagName,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

    final userFromDb = await getUser(email: user.email);
    if (userFromDb != user) {
      throw UserDoesNotExistsException();
    }

    final result = await db.query(
      userTagTable,
      where: 'user_id = ? and tag_name = ?',
      whereArgs: [
        user.userID,
        tagName,
      ],
    );
    if (result.isNotEmpty) {
      throw TagAlreadyExistsException();
    }
    final tagId = await db.insert(
      userTagTable,
      {
        userIdColumn: user.userID,
        tagTextColumn: tagName,
      },
    );
    final userTag = DatabaseTagsForUser(
      tagId: tagId,
      userId: user.userID,
      tagName: tagName,
    );
    dev.log('from user tag: ${userTag.toString()}');
    _tags.add(userTag);
    dev.log('tag list : ${_tags.toString()}');
    _tagStreamController.add(_tags);
    return userTag;
  }

  Future<DatabaseTags> createTag({
    required DatabaseUser user,
    required DatabaseNotes note,
    required String tagName,
    required bool isCheckedForSpecificTag,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    dev.log('from create tag function: ${user.email}');
    final userFromDb = await getUser(email: user.email);
    if (userFromDb != user) {
      throw UserDoesNotExistsException();
    }
    final noteFromDb = await getNote(id: note.noteID);
    if (noteFromDb != note) {
      throw CouldNotFindNoteException();
    }

    final result = await db.query(
      tagTable,
      where: 'user_id = ? and note_id = ? and tag_name = ?',
      whereArgs: [
        user.userID,
        note.noteID,
        tagName,
      ],
    );

    if (result.isNotEmpty) {
      throw TagExistsForSpecificNote();
    }

    final tagId = await db.insert(
      tagTable,
      {
        userIdColumn: user.userID,
        noteIdColumn: note.noteID,
        tagTextColumn: tagName,
        isCheckedColumn: (isCheckedForSpecificTag ? 1 : 0),
      },
    );

    return DatabaseTags(
      tagId: tagId,
      userId: user.userID,
      noteId: note.noteID,
      tagName: tagName,
      isCheckedForSpecificTag: isCheckedForSpecificTag,
    );
  }

  Future<Iterable<DatabaseTags>> getTagsForSpecificNote({
    required DatabaseUser user,
    required DatabaseNotes note,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final userFromDb = await getUser(email: user.email);
    if (userFromDb != user) {
      throw UserDoesNotExistsException();
    }
    final result = await db.query(
      tagTable,
      where: 'user_id = ? and note_id = ?',
      whereArgs: [
        user.userID,
        note.noteID,
      ],
    );
    if (result.isEmpty) {
      throw CouldNotFindTagsException();
    }
    return result.map((e) => DatabaseTags.fromRow(e));
  }

  Future<Iterable<DatabaseTagsForUser>> getTagsForSpecificUser({
    required DatabaseUser user,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final userFromDb = await getUser(email: user.email);
    if (userFromDb != user) {
      throw UserDoesNotExistsException();
    }
    final result = await db.query(
      userTagTable,
      where: 'user_id = ?',
      whereArgs: [
        user.userID,
      ],
    );
    if (result.isEmpty) {
      throw NoTagsAvailableForUserException();
    }
    return result.map((e) => DatabaseTagsForUser.fromRow(e));
  }

  Future<DatabaseTagsForUser> getSpecificTag({
    required DatabaseUser user,
    required DatabaseTagsForUser tag,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final userFromDb = await getUser(email: user.email);
    if (userFromDb != user) {
      throw UserDoesNotExistsException();
    }
    final result = await db.query(
      userTagTable,
      limit: 1,
      where: 'tag_id = ? and user_id = ?',
      whereArgs: [
        tag.tagId,
        user.userID,
      ],
    );
    if (result.isEmpty) {
      throw CouldNotFindTagsException();
    }
    return DatabaseTagsForUser.fromRow(result.first);
  }

  Future<Iterable<DatabaseTagsForUser>> getAllTags(int userId) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTagTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) {
      throw CouldNotFindTagsException();
    }
    return result.map((e) => DatabaseTagsForUser.fromRow(e));
  }

  Future<DatabaseTagsForUser> updateUserTag({
    required DatabaseUser user,
    required DatabaseTagsForUser tag,
    required String tagName,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final updateCount = await db.update(
      userTagTable,
      {
        tagTextColumn: tagName,
      },
      where: 'user_id = ? and tag_id = ?',
      whereArgs: [
        user.userID,
        tag.tagId,
      ],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateTagsException();
    }
    final updatedTag = await getSpecificTag(user: user, tag: tag);
    _tags.removeWhere((element) => element.tagId == tag.tagId);
    _tags.add(updatedTag);
    _tagStreamController.add(_tags);
    return updatedTag;
  }

  Future<DatabaseTagsForUser> updateTag({
    required DatabaseTagsForUser databaseTags,
    required DatabaseUser user,
    required String tagName,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    await getSpecificTag(
      user: user,
      tag: databaseTags,
    );
    final updateCount = await db.update(
      tagTable,
      {
        tagTextColumn: tagName,
      },
      where: 'user_id = ? and tag_name = ?',
      whereArgs: [
        user.userID,
        databaseTags.tagName,
      ],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateTagsException();
    }
    return await updateUserTag(
      user: user,
      tag: databaseTags,
      tagName: tagName,
    );
  }

  Future<void> _deleteUserTag({
    required DatabaseTagsForUser tag,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTagTable,
      where: 'tag_id = ?',
      whereArgs: [
        tag.tagId,
      ],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteTagsException();
    }
    dev.log('deleted from user tag table: ${tag.toString()}');
    _tags.removeWhere((element) => element.tagId == tag.tagId);
    _tagStreamController.add(_tags);
  }

  Future<void> deleteTag({
    required DatabaseUser user,
    required DatabaseTagsForUser databaseTagsForUser,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    try {
      final deleteCount = await db.delete(
        tagTable,
        where: 'user_id = ? and tag_name = ?',
        whereArgs: [
          user.userID,
          databaseTagsForUser.tagName,
        ],
      );
      if (deleteCount == 0) {
        throw CouldNotDeleteTagsException();
      }
    } on CouldNotDeleteTagsException {
      //do nothing
      dev.log('CouldNotDeleteTagsException called!!!');
    }
    dev.log('deleted tag from tag table: ${databaseTagsForUser.toString()}');
    await _deleteUserTag(tag: databaseTagsForUser);
  }

  Future<void> deleteTagFromSpecificNote({
    required DatabaseUser user,
    required DatabaseNotes notes,
    required String tagName,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      tagTable,
      where: 'user_id = ? and note_id = ? and tag_name = ?',
      whereArgs: [
        user.userID,
        notes.noteID,
        tagName,
      ],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteTagFromSpecificNoteException();
    }
  }
}

@immutable
class DatabaseUser {
  final int userID;
  final String email;

  const DatabaseUser({
    required this.userID,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : userID = map[userIdColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $userID, Email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => userID == other.userID;

  @override
  int get hashCode => userID.hashCode;
}

@immutable
class DatabaseNotes {
  final int noteID;
  final int userID;
  final int textColor;
  final String tittle;
  final String text;
  final String imagePath;
  final String date;
  final String time;
  final String repeatStatus;

  const DatabaseNotes({
    required this.noteID,
    required this.userID,
    required this.tittle,
    required this.text,
    required this.imagePath,
    required this.textColor,
    required this.date,
    required this.time,
    required this.repeatStatus,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : noteID = map[noteIdColumn] as int,
        userID = map[userIdColumn] as int,
        tittle = map[noteTittleColumn] as String,
        text = map[noteTextColumn] as String,
        imagePath = map[noteImagePathColumn] as String,
        textColor = map[noteTextColorColumn] as int,
        date = map[remainderDateColumn] as String,
        time = map[remainderTimeColumn] as String,
        repeatStatus = map[remainderRepeatStatusColumn] as String;

  @override
  String toString() =>
      'Notes, Note ID = $noteID, User ID = $userID, Tittle = $tittle, Text = $text, ImagePath = $imagePath, remainder_date = $date, remainder_time = $time, remainder_repeat_status = $repeatStatus';

  @override
  bool operator ==(covariant DatabaseNotes other) => noteID == other.noteID;

  @override
  int get hashCode => noteID.hashCode;
}

@immutable
class DatabaseTags {
  final int tagId;
  final int userId;
  final int noteId;
  final String tagName;
  final bool isCheckedForSpecificTag;

  const DatabaseTags({
    required this.tagId,
    required this.userId,
    required this.noteId,
    required this.tagName,
    required this.isCheckedForSpecificTag,
  });

  DatabaseTags.fromRow(Map<String, Object?> row)
      : tagId = row[tagIdColumn] as int,
        userId = row[userIdColumn] as int,
        noteId = row[noteIdColumn] as int,
        tagName = row[tagTextColumn] as String,
        isCheckedForSpecificTag =
            ((row[isCheckedColumn] as int) == 1 ? true : false);

  @override
  String toString() =>
      'Tag, tag_id = $tagId, user_id = $userId, note_id = $noteId, tag_name = $tagName, is_checked = $isCheckedForSpecificTag';

  @override
  bool operator ==(covariant DatabaseTags other) => tagId == other.tagId;

  @override
  int get hashCode => tagId.hashCode;
}

@immutable
class DatabaseTagsForUser {
  final int tagId;
  final int userId;
  final String tagName;

  const DatabaseTagsForUser({
    required this.tagId,
    required this.userId,
    required this.tagName,
  });

  DatabaseTagsForUser.fromRow(Map<String, Object?> row)
      : tagId = row[tagIdColumn] as int,
        userId = row[userIdColumn] as int,
        tagName = row[tagTextColumn] as String;

  DatabaseTagsForUser.fromDatabaseTags(DatabaseTags databaseTags)
      : tagId = databaseTags.tagId,
        userId = databaseTags.userId,
        tagName = databaseTags.tagName;

  @override
  String toString() =>
      'Tag, tag_id = $tagId, user_id = $userId, tag_name = $tagName';

  @override
  bool operator ==(covariant DatabaseTags other) => tagId == other.tagId;

  @override
  int get hashCode => tagId.hashCode;
}

class DatabaseRemainders {
  final int remainderId;
  final int userId;
  final int noteId;
  final String remainderTime;
  final String remainderDate;
  final String remainderRepeatStatus;

  DatabaseRemainders({
    required this.remainderId,
    required this.userId,
    required this.noteId,
    required this.remainderTime,
    required this.remainderDate,
    required this.remainderRepeatStatus,
  });

  DatabaseRemainders.fromRow(Map<String, Object?> row)
      : remainderId = row[remainderIdColumn] as int,
        userId = row[userIdColumn] as int,
        noteId = row[noteIdColumn] as int,
        remainderTime = row[remainderTimeColumn] as String,
        remainderDate = row[remainderDateColumn] as String,
        remainderRepeatStatus = row[remainderRepeatStatusColumn] as String;

  @override
  String toString() =>
      'Remainder, remainder_id = $remainderId, user_id = $userId, note_id = $noteId, remainder_time = $remainderTime, remainder_date = $remainderDate, remainder_repeat = $remainderRepeatStatus';

  @override
  bool operator ==(covariant DatabaseRemainders other) =>
      remainderId == other.remainderId;

  @override
  int get hashCode => remainderId.hashCode;
}
