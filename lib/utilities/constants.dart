const userIdColumn = 'user_id';
const emailColumn = 'email';
const noteIdColumn = 'note_id';
const tagIdColumn = 'tag_id';
const noteTextColorColumn = 'text_color';
const remainderIdColumn = 'remainder_id';
const tagTextColumn = 'tag_name';
const noteTittleColumn = 'tittle';
const noteTextColumn = 'text';
const remainderTimeColumn = 'remainder_time';
const remainderDateColumn = 'date';
const remainderRepeatStatusColumn = 'repeat_status';
const noteImagePathColumn = 'image_path';
const isCheckedColumn = 'isChecked';
const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const tagTable = 'tag';
const userTagTable = 'user_tags';
const remainderTable = 'remainder';

const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
	$userIdColumn	INTEGER NOT NULL,
	$emailColumn	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("user_id" AUTOINCREMENT)
);
''';

const createNotesTable = '''
CREATE TABLE IF NOT EXISTS "notes" (
	"note_id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"tittle"	TEXT,
	"text"	TEXT,
	"image_path"	TEXT,
	"text_color"	INTEGER NOT NULL,
	"remainder_time"	TEXT,
	"date"	TEXT,
	"repeat_status"	TEXT,
	PRIMARY KEY("note_id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("user_id")
);
''';

const createTagsTable = '''
CREATE TABLE IF NOT EXISTS "tag" (
	"tag_id"	INTEGER NOT NULL UNIQUE,
	"user_id"	INTEGER NOT NULL,
	"tag_name"	TEXT NOT NULL,
	"note_id"	INTEGER NOT NULL,
	"isChecked"	INTEGER NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "user"("user_id"),
	FOREIGN KEY("note_id") REFERENCES "notes"("note_id"),
	PRIMARY KEY("tag_id" AUTOINCREMENT)
);
''';

const createUserTagsTable = '''
CREATE TABLE IF NOT EXISTS "user_tags" (
	"tag_id"	INTEGER NOT NULL UNIQUE,
	"user_id"	INTEGER NOT NULL,
	"tag_name"	TEXT NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "user"("user_id"),
	PRIMARY KEY("tag_id" AUTOINCREMENT)
);
''';

const createRemainderTable = '''
CREATE TABLE IF NOT EXISTS "remainder" (
	"remainder_id"	INTEGER NOT NULL UNIQUE,
	"user_id"	INTEGER NOT NULL,
	"note_id"	INTEGER NOT NULL,
	"remainder_time"	TEXT ,
	"date"	TEXT ,
	"repeat_status"	TEXT ,
	FOREIGN KEY("note_id") REFERENCES "notes"("note_id"),
	FOREIGN KEY("user_id") REFERENCES "user"("user_id"),
	PRIMARY KEY("remainder_id" AUTOINCREMENT)
);
''';

const createOrUpdateNotesRoute = '/note/create_note/';
const loginRoute = '/login/';
const homeRoute = '/home/home_page/';
const showTagsRoute = '/tags/show_tags/';

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
const controllerTag = 'controller';
