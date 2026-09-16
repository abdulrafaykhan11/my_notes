import 'package:flutter/material.dart';
import 'package:mynotes/constant/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_Service.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoutes);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut && context.mounted) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).restorablePushNamedAndRemoveUntil(
                        loginRoutes,
                        (_) => false,
                      );
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<DatabaseUser>(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load notes: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<DatabaseNote>>(
            stream: _notesService.allNote,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Could not load notes: ${snapshot.error}'),
                );
              }

              final allNotes = snapshot.data ?? const <DatabaseNote>[];
              return NoteListView(
                notes: allNotes,
                onDeleteNote: (note) async {
                  await _notesService.deleteNote(id: note.id);
                },
                onTap: (note) {
                  Navigator.of(
                    context,
                  ).pushNamed(createOrUpdateNoteRoutes, arguments: note);
                },
              );
            },
          );
        },
      ),
    );
  }
}
