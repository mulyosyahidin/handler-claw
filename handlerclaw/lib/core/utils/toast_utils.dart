import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String description,
    AnimationType animationType = AnimationType.fromTop,
    Position toastPosition = Position.top,
    Duration toastDuration = const Duration(seconds: 3),
    bool autoDismiss = true,
    Text? action,
    VoidCallback? actionHandler,
  }) {
    CherryToast.success(
      inheritThemeColors: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(description),
      animationType: animationType,
      toastPosition: toastPosition,
      toastDuration: toastDuration,
      autoDismiss: autoDismiss,
      action: action,
      actionHandler: actionHandler,
    ).show(context);
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String description,
    AnimationType animationType = AnimationType.fromTop,
    Position toastPosition = Position.top,
    Duration toastDuration = const Duration(seconds: 3),
    bool autoDismiss = true,
  }) {
    CherryToast.error(
      inheritThemeColors: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(description),
      animationType: animationType,
      toastPosition: toastPosition,
      toastDuration: toastDuration,
      autoDismiss: autoDismiss,
    ).show(context);
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String description,
    AnimationType animationType = AnimationType.fromTop,
    Position toastPosition = Position.top,
    Duration toastDuration = const Duration(seconds: 3),
    bool autoDismiss = true,
  }) {
    CherryToast.warning(
      inheritThemeColors: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(description),
      animationType: animationType,
      toastPosition: toastPosition,
      toastDuration: toastDuration,
      autoDismiss: autoDismiss,
    ).show(context);
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String description,
    AnimationType animationType = AnimationType.fromTop,
    Position toastPosition = Position.top,
    Duration toastDuration = const Duration(seconds: 3),
    bool autoDismiss = true,
  }) {
    CherryToast.info(
      inheritThemeColors: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(description),
      animationType: animationType,
      toastPosition: toastPosition,
      toastDuration: toastDuration,
      autoDismiss: autoDismiss,
    ).show(context);
  }
}
