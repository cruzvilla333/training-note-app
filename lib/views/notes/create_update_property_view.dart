import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:training_note_app/services/auth/auth_tools.dart';
import 'package:training_note_app/services/crud_services/cloud/cloud_note.dart';
import 'package:training_note_app/services/crud_services/cloud/firebase_cloud_storage.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_bloc.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_states.dart';
import 'package:training_note_app/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:training_note_app/utilities/generics/get_arguments.dart';

class CreateUpdatePropertyView extends StatefulWidget {
  const CreateUpdatePropertyView({super.key});

  @override
  State<CreateUpdatePropertyView> createState() =>
      _CreateUpdatePropertyViewState();
}

class _CreateUpdatePropertyViewState extends State<CreateUpdatePropertyView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _firebaseCloudStorageService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _firebaseCloudStorageService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textController.text;

    await _firebaseCloudStorageService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setUpTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(
      {required BuildContext context, required CrudState state}) async {
    final thisState = state as CrudStateGoToGetOrCreateProperty;
    final widgetNote = thisState.property;

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final newNote =
        await _firebaseCloudStorageService.createNote(ownerUserId: user().id);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _firebaseCloudStorageService.deleteNote(
          documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _firebaseCloudStorageService.updateNote(
        documentId: note.documentId,
        text: _textController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CrudBloc, CrudState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state is CrudStateGoToGetOrCreateProperty
                ? state.property == null
                    ? 'New property'
                    : 'Edit property'
                : 'Error state'),
            // actions: [
            //   IconButton(
            //     onPressed: () async {
            //       final text = _textController.text;
            //       if (_note == null || text.isEmpty) {
            //         await showCannotShareEmptyNoteDialog(context);
            //       } else {
            //         Share.share(text);
            //       }
            //     },
            //     icon: const Icon(Icons.share),
            //   ),
            // ],
          ),
          body: FutureBuilder(
            future: createOrGetExistingNote(context: context, state: state),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _setUpTextControllerListener();
                  return TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Start typing your notes...',
                    ),
                  );
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        );
      },
    );
  }
}
