import 'package:bloc/bloc.dart';
import 'package:mynotes/services/cloud/bloc/notes_event.dart';
import 'package:mynotes/services/cloud/bloc/notes_state.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FirebaseCloudStorage _notesService;
  final String _ownerUserId;

  NotesBloc(this._notesService, this._ownerUserId)
    : super(const NotesStateLoading()) {
    on<NotesEventLoad>((event, emit) {
      emit(const NotesStateLoading());
      emit.forEach<Iterable<CloudNote>>(
        _notesService.allNotes(ownerUserId: _ownerUserId),
        onData: (notes) => NotesStateLoaded(notes),
        onError: (error, stackTrace) => NotesStateError(error),
      );
    });

    on<NotesEventDelete>((event, emit) async {
      try {
        await _notesService.deleteNote(documentId: event.note.documentId);
      } catch (error) {
        emit(NotesStateError(error));
      }
    });
  }
}
