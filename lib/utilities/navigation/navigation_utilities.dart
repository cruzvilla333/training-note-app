import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_states.dart';

import '../../services/crud_services/crud_bloc/crud_bloc.dart';
import '../../services/crud_services/crud_bloc/crud_events.dart';
import '../../views/forgot_password_view.dart';

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}

var navigationStack = Stack<Object>();

void lastPage({required BuildContext context}) {
  var navigator = navigationStack.pop();
  navigator = navigationStack.pop();
  if (navigator is CrudEvent) {
    context.read<CrudBloc>().add(navigator);
  }
}

void currentPage({required BuildContext context}) {
  var navigator = navigationStack.pop();
  if (navigator is CrudEvent) {
    context.read<CrudBloc>().add(navigator);
  }
}

// void shiftToPage({
//   required BuildContext context,
//   required Widget page,
// }) {
//   Navigator.pushAndRemoveUntil(
//       context, MaterialPageRoute(builder: (context) => page), (route) => false);
// }
