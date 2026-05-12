import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double value = double.parse(cleanedText);
    final formatter = NumberFormat.decimalPattern('vi_VN');
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
