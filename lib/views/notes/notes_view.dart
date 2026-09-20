import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constant/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/bloc/notes_bloc.dart';
import 'package:mynotes/services/cloud/bloc/notes_event.dart';
import 'package:mynotes/services/cloud/bloc/notes_state.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(const NotesEventLoad());
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
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesStateError) {
            return Center(child: Text('Could not load notes: ${state.error}'));
          }

          if (state is NotesStateLoaded) {
            return NoteListView(
              notes: state.notes,
              onDeleteNote: (note) {
                context.read<NotesBloc>().add(NotesEventDelete(note));
              },
              onTap: (note) {
                Navigator.of(
                  context,
                ).pushNamed(createOrUpdateNoteRoutes, arguments: note);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
