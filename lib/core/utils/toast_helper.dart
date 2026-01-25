import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  ToastHelper._();

  static void showSuccess(String message) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
    );
  }

  static void showError(String message, {String? details}) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      description: details != null ? Text(details) : null,
      autoCloseDuration: const Duration(seconds: 6),
      alignment: Alignment.topCenter,
    );
  }

  static void showWarning(String message) {
    toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
    );
  }

  static void showInfo(String message) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
    );
  }
}
