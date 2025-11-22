import 'package:flutter/material.dart';

/// Helper class for Markdown formatting operations
class MarkdownHelper {
  /// Wraps the selected text with the given markdown syntax
  /// Supports single words, multiple words, phrases, and multiple lines
  static void wrapSelection(
    TextEditingController controller,
    String prefix,
    String suffix,
  ) {
    final selection = controller.selection;
    final text = controller.text;

    // Handle both collapsed cursor and any selection
    int start = selection.baseOffset;
    int end = selection.extentOffset;

    // Ensure start <= end
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    // Get the selected text or use empty string if nothing is selected
    final selectedText = start == end ? '' : text.substring(start, end);

    // Create the new text with markdown wrapper
    final newText = '$prefix$selectedText$suffix';

    // Replace the selected text with the wrapped version
    final beforeSelection = text.substring(0, start);
    final afterSelection = text.substring(end);
    final fullText = '$beforeSelection$newText$afterSelection';

    // Calculate new cursor position
    // If there was a selection, place cursor after the wrapped text
    // If no selection, place cursor between prefix and suffix for typing
    final newCursorPos = selectedText.isEmpty
        ? start + prefix.length
        : start + newText.length;

    controller.value = TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Inserts markdown syntax at cursor position for block-level elements
  /// (headings, lists, quotes, etc.)
  static void insertAtCursor(
    TextEditingController controller,
    String markdown, {
    bool newLine = false,
  }) {
    final selection = controller.selection;
    final text = controller.text;

    final beforeCursor = selection.textBefore(text);
    final afterCursor = selection.textAfter(text);

    // Add newline before if requested and not at start of text
    final prefix =
        (newLine && beforeCursor.isNotEmpty && !beforeCursor.endsWith('\n'))
        ? '\n'
        : '';

    final fullText = '$beforeCursor$prefix$markdown$afterCursor';

    // Place cursor at the end of inserted markdown
    final newCursorPos = beforeCursor.length + prefix.length + markdown.length;

    controller.value = TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Formats selected text or current line as a heading
  static void formatHeading(TextEditingController controller, int level) {
    final selection = controller.selection;
    final text = controller.text;

    // Get the current line
    final beforeCursor = selection.textBefore(text);
    final lineStart = beforeCursor.lastIndexOf('\n') + 1;
    final afterCursor = selection.textAfter(text);
    final lineEndInAfter = afterCursor.indexOf('\n');
    final lineEnd = lineEndInAfter == -1
        ? text.length
        : selection.end + lineEndInAfter;

    final line = text.substring(lineStart, lineEnd);
    final prefix = '#' * level + ' ';

    // Remove existing heading if present
    final cleanLine = line.replaceFirst(RegExp(r'^#+\s*'), '');

    final newLine = '$prefix$cleanLine';
    final beforeLine = text.substring(0, lineStart);
    final afterLine = text.substring(lineEnd);

    final fullText = '$beforeLine$newLine$afterLine';

    controller.value = TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: lineStart + newLine.length),
    );
  }

  /// Toggles list formatting for selected lines
  static void toggleList(
    TextEditingController controller, {
    bool ordered = false,
  }) {
    final selection = controller.selection;
    final text = controller.text;

    // Get selected text including full lines
    final beforeSelection = selection.textBefore(text);
    final lineStart = beforeSelection.lastIndexOf('\n') + 1;
    final afterSelection = selection.textAfter(text);
    final lineEndInAfter = afterSelection.indexOf('\n');
    final lineEnd = lineEndInAfter == -1
        ? text.length
        : selection.end + lineEndInAfter;

    final selectedLines = text.substring(lineStart, lineEnd);
    final lines = selectedLines.split('\n');

    final newLines = <String>[];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final prefix = ordered ? '${i + 1}. ' : '- ';

      // Check if line already has list formatting
      if (line.startsWith(RegExp(r'^\d+\.\s')) || line.startsWith('- ')) {
        // Remove list formatting
        newLines.add(line.replaceFirst(RegExp(r'^(\d+\.\s|-\s)'), ''));
      } else {
        // Add list formatting
        newLines.add('$prefix$line');
      }
    }

    final newText = newLines.join('\n');
    final beforeLine = text.substring(0, lineStart);
    final afterLine = text.substring(lineEnd);

    final fullText = '$beforeLine$newText$afterLine';

    controller.value = TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: lineStart + newText.length),
    );
  }
}
