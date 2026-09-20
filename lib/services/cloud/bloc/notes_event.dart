import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/cloud/cloud_note.dart';

@immutable
abstract class NotesEvent {
  const NotesEvent();
}

class NotesEventLoad extends NotesEvent {
  const NotesEventLoad();
}

class NotesEventDelete extends NotesEvent {
  final CloudNote note;

  const NotesEventDelete(this.note);
}
