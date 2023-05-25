import 'dart:async';

import 'package:birthday_reminder/layouts/bottom_popup.dart';
import 'package:flutter/material.dart';

void showConfirmDialog(
  BuildContext context, {
  double height = 200,
  required void Function(bool result) onInput,
  Widget? title,
  Widget? child,
  bool acceptOnly = false,
}) {
  Navigator.of(context).push(
    BottomPopupRoute(
      height: height,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          onInput(false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: title,
            automaticallyImplyLeading: false,
          ),
          primary: true,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: child,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (i) {
              Navigator.of(context).pop();
              if (i == 0) onInput(false);
              onInput(true);
            },
            destinations: [
              if (!acceptOnly) NavigationDestination(icon: const Icon(Icons.close), label: 'Cancelar'),
              if (acceptOnly) SizedBox.shrink(),
              NavigationDestination(icon: const Icon(Icons.check), label: 'Acpetar'),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  double height = 200,
  required void Function(bool result) onInput,
  Widget? title,
  Widget? content,
  bool acceptOnly = false,
}) {
  final completer = Completer<bool>();

  showConfirmDialog(
    context,
    onInput: completer.complete,
    child: content,
    height: height,
    title: title,
    acceptOnly: acceptOnly,
  );

  return completer.future;
}
