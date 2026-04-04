import 'package:flutter/material.dart';
import 'package:taroshell/core/constants/app_constants.dart';

/// A reusable search text field with a leading search icon and an optional
/// clear button that appears when the field is non-empty.
///
/// Integrates with the application theme for consistent styling.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search...',
    this.autofocus = false,
  });

  /// Optional external controller. If not provided, an internal one is used.
  final TextEditingController? controller;

  /// Callback fired on every text change (debounced externally if needed).
  final ValueChanged<String>? onChanged;

  /// Callback fired when the clear button is pressed.
  final VoidCallback? onClear;

  /// Placeholder text displayed when the field is empty.
  final String hintText;

  /// Whether the field should request focus on mount.
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    // Trigger rebuild to show/hide clear button.
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return SizedBox(
      height: AppConstants.titleBarHeight,
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: theme.textTheme.bodyMedium,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: _handleClear,
                  splashRadius: 16,
                  tooltip: 'Clear search',
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
