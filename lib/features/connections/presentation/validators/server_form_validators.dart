import 'package:taroshell/core/constants/app_constants.dart';

/// Validation boundaries for server connection form fields.
///
/// Centralises limits used by both [ServerFormDialog] and the quick-connect
/// dialog so that validation is consistent and magic numbers are avoided.
abstract final class FormLimits {
  static const int portMin = 1;
  static const int portMax = AppConstants.portMax;
  static const int labelMaxLength = 200;
  static const int hostMaxLength = 255;
  static const int usernameMaxLength = 128;
}

/// Reusable validators for server connection forms.
///
/// All validators return `null` on success and a human-readable error message
/// on failure, matching the contract expected by `TextFormField.validator`.
abstract final class ServerFormValidators {
  static String? label(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Label is required';
    }
    if (value.length > FormLimits.labelMaxLength) {
      return 'Label must be ${FormLimits.labelMaxLength} characters or fewer';
    }
    return null;
  }

  static String? host(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host is required';
    }
    if (value.length > FormLimits.hostMaxLength) {
      return 'Host must be ${FormLimits.hostMaxLength} characters or fewer';
    }
    if (value.contains(' ')) {
      return 'Host must not contain spaces';
    }
    return null;
  }

  static String? port(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Port must be a number';
    }
    if (port < FormLimits.portMin || port > FormLimits.portMax) {
      return 'Port must be between ${FormLimits.portMin} and ${FormLimits.portMax}';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length > FormLimits.usernameMaxLength) {
      return 'Username must be ${FormLimits.usernameMaxLength} characters or fewer';
    }
    return null;
  }
}
