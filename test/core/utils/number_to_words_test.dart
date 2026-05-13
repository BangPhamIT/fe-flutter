import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/core/utils/number_to_words.dart';

void main() {
  group('NumberToWords.convert', () {
    test('nên trả về "Không đồng" khi số tiền là 0', () {
      expect(NumberToWords.convert(0), 'Không đồng');
    });

    test('nên chuyển đổi đúng các số hàng đơn vị', () {
      expect(NumberToWords.convert(1), 'Một đồng');
      expect(NumberToWords.convert(5), 'Năm đồng');
      expect(NumberToWords.convert(9), 'Chín đồng');
    });

    test('nên chuyển đổi đúng các số hàng chục', () {
      expect(NumberToWords.convert(10), 'Mười đồng');
      expect(NumberToWords.convert(11), 'Mười một đồng');
      expect(NumberToWords.convert(15), 'Mười lăm đồng');
      expect(NumberToWords.convert(20), 'Hai mươi đồng');
      expect(NumberToWords.convert(21), 'Hai mươi mốt đồng');
      expect(NumberToWords.convert(25), 'Hai mươi lăm đồng');
    });

    test('nên chuyển đổi đúng các số hàng trăm', () {
      expect(NumberToWords.convert(100), 'Một trăm đồng');
      expect(NumberToWords.convert(101), 'Một trăm lẻ một đồng');
      expect(NumberToWords.convert(110), 'Một trăm mười đồng');
      expect(NumberToWords.convert(115), 'Một trăm mười lăm đồng');
      expect(NumberToWords.convert(125), 'Một trăm hai mươi lăm đồng');
    });

    test('nên chuyển đổi đúng các số hàng ngàn', () {
      expect(NumberToWords.convert(1000), 'Một ngàn đồng');
      expect(NumberToWords.convert(1001), 'Một ngàn không trăm lẻ một đồng');
      expect(NumberToWords.convert(1010), 'Một ngàn không trăm mười đồng');
      expect(NumberToWords.convert(1100), 'Một ngàn một trăm đồng');
      expect(NumberToWords.convert(1500500), 'Một triệu năm trăm ngàn năm trăm đồng');
    });

    test('nên chuyển đổi đúng các số tiền lớn', () {
      expect(
        NumberToWords.convert(123456789),
        'Một trăm hai mươi ba triệu bốn trăm năm mươi sáu ngàn bảy trăm tám mươi chín đồng',
      );
    });

    test('nên chuyển đổi đúng các số tròn triệu, tròn tỷ', () {
      expect(NumberToWords.convert(1000000), 'Một triệu đồng');
      expect(NumberToWords.convert(1000000000), 'Một tỷ đồng');
    });

    test('nên chuyển đổi đúng các số có nhóm số 0 ở giữa', () {
      expect(NumberToWords.convert(1000001), 'Một triệu không trăm lẻ một đồng');
      expect(NumberToWords.convert(1000100), 'Một triệu không trăm ngàn một trăm đồng');
      expect(NumberToWords.convert(1001001), 'Một triệu không trăm lẻ một ngàn không trăm lẻ một đồng');
    });

    test('nên áp dụng đúng quy tắc "lăm" và "năm"', () {
      expect(NumberToWords.convert(5), 'Năm đồng');
      expect(NumberToWords.convert(15), 'Mười lăm đồng');
      expect(NumberToWords.convert(105), 'Một trăm lẻ năm đồng');
      expect(NumberToWords.convert(115), 'Một trăm mười lăm đồng');
      expect(NumberToWords.convert(125), 'Một trăm hai mươi lăm đồng');
    });

    test('nên áp dụng đúng quy tắc "mốt" và "một"', () {
      expect(NumberToWords.convert(1), 'Một đồng');
      expect(NumberToWords.convert(11), 'Mười một đồng');
      expect(NumberToWords.convert(21), 'Hai mươi mốt đồng');
      expect(NumberToWords.convert(101), 'Một trăm lẻ một đồng');
      expect(NumberToWords.convert(121), 'Một trăm hai mươi mốt đồng');
    });

    test('nên xử lý được số cực lớn (ngàn tỷ, triệu tỷ)', () {
      expect(
        NumberToWords.convert(1000000000000),
        'Một ngàn tỷ đồng',
      );
      expect(
        NumberToWords.convert(1000000000000000),
        'Một triệu tỷ đồng',
      );
    });

    test('nên xử lý an toàn cho số âm bằng cách lấy giá trị tuyệt đối hoặc floor', () {
      // Hiện tại code đang dùng floor(), nên -1.5 sẽ thành -2.
      // Chúng ta nên đảm bảo nó không gây crash, hoặc điều chỉnh logic nếu cần.
      expect(NumberToWords.convert(-1), 'Không đồng'); // Hoặc logic tùy bạn muốn
    });
  });
}
