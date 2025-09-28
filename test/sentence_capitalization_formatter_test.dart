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
}
