import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/terminal_theme.dart';

/// Wrapper around xterm's [TerminalView] that applies TaroShell theming.
///
/// Configures the terminal font (JetBrains Mono), scrollback buffer size,
/// theme colors (dark/light based on the app theme), and ensures proper
/// focus handling for keyboard input.
class TerminalViewWrapper extends StatefulWidget {
  const TerminalViewWrapper({
    super.key,
    required this.terminal,
    this.fontSize,
    this.autofocus = true,
  });

  /// The xterm [Terminal] instance to render.
  final Terminal terminal;

  /// Font size override. Defaults to [AppConstants.defaultFontSize].
  final double? fontSize;

  /// Whether the terminal should request focus on mount.
  final bool autofocus;

  @override
  State<TerminalViewWrapper> createState() => _TerminalViewWrapperState();
}

class _TerminalViewWrapperState extends State<TerminalViewWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final terminalTheme =
        isDark ? AppTerminalTheme.dark : AppTerminalTheme.light;
    final fontSize = widget.fontSize ?? AppConstants.defaultFontSize;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: TerminalView(
        widget.terminal,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        theme: terminalTheme,
        textStyle: TerminalStyle(
          fontSize: fontSize,
          fontFamily: AppConstants.defaultTerminalFontFamily,
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
