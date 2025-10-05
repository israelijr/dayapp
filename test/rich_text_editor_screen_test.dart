import 'package:flutter_test/flutter_test.dart';
import 'package:dayapp/screens/rich_text_editor_screen.dart';

void main() {
  test('RichTextEditorScreen has SentenceCapitalizationTextInputFormatter', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: 'primeira frase. segunda frase');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Primeira frase. Segunda frase');
  });

  test('RichTextEditorScreen capitalizes after line breaks', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: 'primeira linha\nsegunda linha');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Primeira linha\nSegunda linha');
  });

  test('RichTextEditorScreen handles empty text', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: '');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, '');
  });
}
