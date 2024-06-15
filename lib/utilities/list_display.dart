import 'package:mynotes_x/services/crud/notes_service.dart';

String getAsList(List<NoteList> noteLists) {
  String text = '';
  for (final noteList in noteLists) {
    text += noteList.text!;
    text += '\n';
  }
  return text;
}
