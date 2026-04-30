import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'CONFIRM',
  String cancelLabel = 'CANCEL',
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(cancelLabel)),
        TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}
