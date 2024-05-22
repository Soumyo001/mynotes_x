const userIdColumn = 'user_id';
const emailColumn = 'email';
const noteIdColumn = 'note_id';
const noteTittle = 'tittle';
const noteText = 'text';
const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const createUserTable = '''
CREATE TABLE IF NOT EXISTS"user" (
	$userIdColumn	INTEGER NOT NULL,
	$emailColumn	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("user_id" AUTOINCREMENT)
);
''';
const createNotesTable = '''
CREATE TABLE IF NOT EXISTS "notes" (
	$noteIdColumn	INTEGER NOT NULL,
	$userIdColumn	INTEGER NOT NULL,
	$noteTittle	TEXT,
	$noteText	TEXT,
	FOREIGN KEY("user_id") REFERENCES "user"("user_id"),
	PRIMARY KEY("note_id" AUTOINCREMENT)
);
''';
const createNotesRoute = '/note/create_note/';
const loginRoute = '/login/';
const homeRoute = '/home/home_page/';

const notificationNoRepeat = 'No Repeat';
const notificationRepeatDaily = 'Repeat Daily';
const notificationRepeatWeekly = 'Repeat Weekly';

const saturday = 'saturday';
const sunday = 'sunday';
const monday = 'monday';
const tuesday = 'tuesday';
const wednesday = 'wednesday';
const thursday = 'thursday';
const friday = 'friday';

const weekTag = 'week';
const tagTag = 'tag';
const checkedTag = 'isChecked';
