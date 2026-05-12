class NumberToWords {
  static const List<String> _units = [
    '',
    'ngàn',
    'triệu',
    'tỷ',
    'ngàn tỷ',
    'triệu tỷ',
  ];
  static const List<String> _digits = [
    'không',
    'một',
    'hai',
    'ba',
    'bốn',
    'năm',
    'sáu',
    'bảy',
    'tám',
    'chín',
  ];

  static String convert(double amount) {
    int num = amount.floor();
    if (num == 0) return 'Không đồng';

    String words = '';
    int unitIndex = 0;

    do {
      int threeDigits = num % 1000;
      if (threeDigits > 0) {
        String part = _readThreeDigits(
          threeDigits,
          unitIndex > 0 && num >= 1000,
        );
        words = '$part ${_units[unitIndex]} $words';
      }
      num = num ~/ 1000;
      unitIndex++;
    } while (num > 0);

    String result = words.trim();
    if (result.isEmpty) return 'Không đồng';

    result = '${result[0].toUpperCase()}${result.substring(1)} đồng';
    return result.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _readThreeDigits(int n, bool showZero) {
    String res = '';
    int hundred = n ~/ 100;
    int ten = (n % 100) ~/ 10;
    int unit = n % 10;

    if (hundred > 0 || showZero) {
      res += '${_digits[hundred]} trăm ';
    }

    if (ten > 0) {
      if (ten == 1) {
        res += 'mười ';
      } else {
        res += '${_digits[ten]} mươi ';
      }
    } else if (hundred > 0 && unit > 0) {
      res += 'lẻ ';
    }

    if (unit > 0) {
      if (unit == 1 && ten > 1) {
        res += 'mốt';
      } else if (unit == 5 && ten > 0) {
        res += 'lăm';
      } else {
        res += _digits[unit];
      }
    }

    return res.trim();
  }
}
