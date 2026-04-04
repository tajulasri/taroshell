import 'package:flutter/material.dart';

/// Dialog prompting the user for a password or passphrase during SSH
/// connection setup.
///
/// Returns the entered string, or `null` if the user cancels.
class PasswordPromptDialog extends StatefulWidget {
  const PasswordPromptDialog._({
    required this.title,
    required this.labelText,
  });

  final String title;
  final String labelText;

  /// Shows the dialog and returns the entered credential, or `null` on cancel.
  ///
  /// When [isPassphrase] is `true`, the dialog labels reflect a key passphrase
  /// rather than an account password.
  static Future<String?> show(
    BuildContext context, {
    bool isPassphrase = false,
  }) {
    final title = isPassphrase ? 'SSH Key Passphrase' : 'SSH Password';
    final label = isPassphrase ? 'Passphrase' : 'Password';

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordPromptDialog._(
        title: title,
        labelText: label,
      ),
    );
  }

  @override
  State<PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<PasswordPromptDialog> {
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text;
    if (value.isNotEmpty) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: TextField(
          controller: _controller,
          autofocus: true,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: widget.labelText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
