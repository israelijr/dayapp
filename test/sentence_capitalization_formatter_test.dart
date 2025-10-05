import 'package:flutter_test/flutter_test.dart';
import 'package:dayapp/screens/create_historia_screen.dart';

void main() {
  test('capitalizes first letter and after sentence endings', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: 'hello. how are you? i am fine!');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text.startsWith('Hello.'), true);
    expect(result.text.contains(' How'), true);
    expect(result.text.contains(' I am'), true);
  });

  test('keeps empty text unchanged', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: '');
    final result = formatter.formatEditUpdate(oldValue, newValue);
    expect(result.text, '');
  });

  test('capitalizes after line breaks', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(
      text: 'primeira linha.\nesta é a segunda linha',
    );
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text.startsWith('Primeira linha.'), true);
    expect(result.text.contains('\nEsta é'), true);
  });

  test('handles multiple spaces after punctuation', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: 'fim da frase.   próxima frase');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Fim da frase.   Próxima frase');
  });

  test('handles text starting with lowercase', () {
    final formatter = SentenceCapitalizationTextInputFormatter();
    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(text: 'hoje foi um bom dia');
    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, 'Hoje foi um bom dia');
  });
}
