import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_note_app/constants/regular_expressions.dart';
import 'package:training_note_app/designs/colors/app_colors.dart';
import 'package:training_note_app/services/auth/auth_tools.dart';
import 'package:training_note_app/services/crud_services/cloud/cloud_property.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_bloc.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_events.dart';
import 'package:training_note_app/services/crud_services/crud_bloc/crud_states.dart';
import 'package:training_note_app/utilities/dialogs/error_dialog.dart';
import 'package:training_note_app/utilities/navigation/navigation_utilities.dart';

import '../../services/crud_services/crud_utilities.dart';

class CreateUpdatePropertyView extends StatefulWidget {
  final CrudStateGetProperty state;
  const CreateUpdatePropertyView({super.key, required this.state});

  @override
  State<CreateUpdatePropertyView> createState() =>
      _CreateUpdatePropertyViewState();
}

class _CreateUpdatePropertyViewState extends State<CreateUpdatePropertyView> {
  late final CloudProperty? _property;
  late final TextEditingController _titleController;
  late final TextEditingController _addressController;
  late final TextEditingController _monthlyPriceController;
  late final TextEditingController _moneyDueController;
  final _updateOrCreatePropertyForm = GlobalKey<FormState>();
  @override
  void initState() {
    _property = widget.state.property;
    _titleController = TextEditingController();
    _addressController = TextEditingController();
    _monthlyPriceController = TextEditingController();
    _moneyDueController = TextEditingController();
    int moneyDue = widget.state.property?.moneyDue ?? 0;
    _moneyDueController.text = moneyDue == 0
        ? '0'
        : moneyDue.toString().replaceAllMapped(reg, mathFunc);
    _titleController.text = widget.state.property?.title ?? '';
    _addressController.text = widget.state.property?.address ?? '';
    int monthlyPrice = widget.state.property?.monthlyPrice ?? 0;
    _monthlyPriceController.text = monthlyPrice == 0
        ? ''
        : monthlyPrice.toString().replaceAllMapped(reg, mathFunc);
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _monthlyPriceController.dispose();
    _moneyDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudBloc, CrudState>(
      listener: (context, state) async {
        if (state.exception != null) {
          await showErrorDialog(context, state.exception.toString());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainAppBarColor,
          title: Text(
            _property == null ? 'New property' : 'Edit property',
            style: TextStyle(color: mainAppTextColor),
          ),
          actions: [
            _property != null
                ? IconButton(
                    color: mainAppIconColor,
                    onPressed: () async {
                      final deleted = await attemptPropertyDeletion(
                          context: context, property: _property!);
                      if (deleted == true) {
                        lastPage(context: context);
                      }
                    },
                    icon: const Icon(Icons.delete))
                : const SizedBox(height: 0, width: 0),
            IconButton(
                color: mainAppIconColor,
                onPressed: () {
                  if (_updateOrCreatePropertyForm.currentState!.validate()) {
                    final property = CloudProperty(
                      documentId: _property?.documentId ?? '',
                      ownerUserId: user().id,
                      title: _titleController.text,
                      address: _addressController.text,
                      monthlyPrice: int.parse(_monthlyPriceController.text
                          .replaceAll(RegExp(r','), '')),
                      moneyDue: int.parse(_moneyDueController.text
                          .replaceAll(RegExp(r','), '')),
                    );
                    context
                        .read<CrudBloc>()
                        .add(CrudEventCreateOrUpdateProperty(
                          property: property,
                        ));
                    lastPage(context: context);
                  }
                },
                icon: const Icon(Icons.check)),
            IconButton(
                color: mainAppIconColor,
                onPressed: () => lastPage(context: context),
                icon: const Icon(Icons.clear))
          ],
        ),
        body: Builder(
          builder: (context) {
            return Form(
              key: _updateOrCreatePropertyForm,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field needs value';
                        }
                        return null;
                      },
                      controller: _titleController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Title...',
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field needs value';
                        }
                        return null;
                      },
                      controller: _addressController,
                      keyboardType: TextInputType.streetAddress,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Address...',
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field needs value';
                        }
                        return null;
                      },
                      controller: _monthlyPriceController,
                      keyboardType: TextInputType.number,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Monthly price...',
                        labelText: 'Monthly price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _property != null
                        ? TextFormField(
                            validator: (value) {
                              if (_property == null) return null;
                              if (value == null || value.isEmpty) {
                                return 'This field needs value';
                              }
                              return null;
                            },
                            controller: _moneyDueController,
                            keyboardType: TextInputType.number,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Money due...',
                              labelText: 'Money due',
                              border: OutlineInputBorder(),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                            width: 0,
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
