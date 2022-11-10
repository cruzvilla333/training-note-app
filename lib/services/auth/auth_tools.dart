import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_note_app/services/auth/auth_exceptions.dart';
import 'package:training_note_app/services/auth/auth_service.dart';
import 'package:training_note_app/services/auth/auth_user.dart';
import '../../utilities/dialogs/error_dialog.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_events.dart';
import 'bloc/auth_states.dart';

Future<void> attemptLogIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    context.read<AuthBloc>().add(AuthEventLogIn(
          email,
          password,
        ));
  } on AuthStateLogInFailure catch (e) {
    await showErrorDialog(context, e.exception.toString());
    rethrow;
  }
}

Future<void> attemptLogOut({
  required BuildContext context,
}) async {
  try {
    context.read<AuthBloc>().add(
          const AuthEventLogOut(),
        );
  } catch (e) {
    await showErrorDialog(context, e.toString());
    rethrow;
  }
}

Future<AuthUser> tryFirebaseRegister({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    final user = await AuthService.firebase().createUser(
      email: email,
      password: password,
    );
    await AuthService.firebase().sendEmailVerification();
    return user;
  } catch (e) {
    await showErrorDialog(context, e.toString());
    rethrow;
  }
}

AuthUser user() {
  final user = AuthService.firebase().currentUser;
  if (user != null) {
    return user;
  } else {
    throw UserNotLoggedInAuthException();
  }
}
