import 'package:dayapp/screens/rich_text_editor_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RichTextEditorScreen has SentenceCapitalizationTextInputFormatter', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    const oldValue = TextEditingValue(text: '');
    const newValue = TextEditingValue(text: 'primeira frase. segunda frase');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Primeira frase. Segunda frase');
  });

  test('RichTextEditorScreen capitalizes after line breaks', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    const oldValue = TextEditingValue(text: '');
    const newValue = TextEditingValue(text: 'primeira linha\nsegunda linha');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Primeira linha\nSegunda linha');
  });

  test('RichTextEditorScreen handles empty text', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    const oldValue = TextEditingValue(text: '');
    const newValue = TextEditingValue(text: '');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, '');
  });
}
