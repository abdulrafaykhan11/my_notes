import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/cloud/cloud_note.dart';

@immutable
abstract class NotesState {
  const NotesState();
}

class NotesStateLoading extends NotesState {
  const NotesStateLoading();
}

class NotesStateLoaded extends NotesState {
  final Iterable<CloudNote> notes;

  const NotesStateLoaded(this.notes);
}

class NotesStateError extends NotesState {
  final Object error;

  const NotesStateError(this.error);
}
