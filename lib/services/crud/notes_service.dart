import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes_x/services/crud/crud_exceptions.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  List<DatabaseNotes> _notes = [];

  final _noteStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();

  Stream<List<DatabaseNotes>> get allNotes => _noteStreamController.stream;

  NotesService._sharedObject();
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
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoesNotExistsException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheAllNotes() async {
    final allNotes = await getAllNote();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
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
      await _cacheAllNotes();
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
    final noteID = await db.insert(
      notesTable,
      {
        userIdColumn: user.userID,
        noteTittle: tittle,
        noteText: text,
      },
    );
    final note = DatabaseNotes(
      noteID: noteID,
      userID: user.userID,
      tittle: tittle,
      text: text,
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

  Future<Iterable<DatabaseNotes>> getAllNote() async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
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
    required String text,
  }) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    await getNote(
      id: noteToBeUpdated.noteID,
    );
    final updateCount = await db.update(
      notesTable,
      {
        noteTittle: tittle,
        noteText: text,
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
        (databaseNote) => databaseNote.noteID == updatedNote.noteID);
    _notes.add(updatedNote);
    _noteStreamController.add(_notes);
    return updatedNote;
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
  final String tittle;
  final String text;

  const DatabaseNotes({
    required this.noteID,
    required this.userID,
    required this.tittle,
    required this.text,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : noteID = map[noteIdColumn] as int,
        userID = map[userIdColumn] as int,
        tittle = map[noteTittle] as String,
        text = map[noteText] as String;

  @override
  String toString() =>
      'Notes, Note ID = $noteID, User ID = $userID, Tittle = $tittle, Text = $text';

  @override
  bool operator ==(covariant DatabaseNotes other) => noteID == other.noteID;

  @override
  int get hashCode => noteID.hashCode;
}
