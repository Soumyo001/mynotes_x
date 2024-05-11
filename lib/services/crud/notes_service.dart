import 'package:flutter/material.dart';
import 'package:mynotes_x/services/crud/crud_exceptions.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

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
    final documentPath = await getApplicationDocumentsDirectory();
    final designatedPath = join(documentPath.path, dbName);
    final db = await openDatabase(designatedPath);
    _db = db;
    await db.execute(createUserTable);
    await db.execute(createNotesTable);
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
    return DatabaseNotes(
      noteID: noteID,
      userID: user.userID,
      tittle: tittle,
      text: text,
    );
  }

  Future<DatabaseNotes> getNote({required int id}) async {
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
    return DatabaseNotes.fromRow(result.first);
  }

  Future<Iterable<DatabaseNotes>> getAllNote() async {
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
  }

  Future<int> deleteAllNote() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String? tittle,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(
      id: note.noteID,
    );
    final updateCount = await db.update(
      notesTable,
      {
        noteTittle: tittle,
        noteText: text,
      },
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNotesException();
    }
    return await getNote(id: note.noteID);
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
