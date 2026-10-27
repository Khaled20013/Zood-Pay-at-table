import 'package:flutter/material.dart';

/// Floating snackbar that clears the menu's floating cart bar on narrow
/// layouts (the bar is replaced by a side panel at >= [sidePanelBreakpoint]).
SnackBar menuSnackBar(
  BuildContext context, {
  required String message,
  SnackBarAction? action,
  Duration duration = const Duration(milliseconds: 1800),
}) {
  const sidePanelBreakpoint = 1000.0;
  final narrow = MediaQuery.sizeOf(context).width < sidePanelBreakpoint;
  return SnackBar(
    content: Text(message),
    action: action,
    duration: duration,
    // Snackbars with an action persist by default; these are transient.
    persist: false,
    margin: EdgeInsets.fromLTRB(16, 0, 16, narrow ? 96 : 16),
  );
}
