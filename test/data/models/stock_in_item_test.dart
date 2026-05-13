import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/data/models/stock_in_item.dart';

void main() {
  group('StockInItem Model', () {
    final testJson = {
      'id': 'item1',
      'productCode': 'P001',
      'productName': 'Sản phẩm 1',
      'unit': 'Cái',
      'quantityDocument': 10,
      'quantityActual': 9,
      'unitPrice': 100000,
      'totalPrice': 900000,
    };

    test('nên parse từ JSON đúng cấu trúc', () {
      final item = StockInItem.fromJson(testJson);

      expect(item.id, 'item1');
      expect(item.productName, 'Sản phẩm 1');
      expect(item.quantityActual, 9.0);
      expect(item.totalPrice, 900000.0);
    });

    test('nên chuyển đổi sang JSON đúng cấu trúc', () {
      final item = StockInItem.fromJson(testJson);
      final json = item.toJson();

      expect(json['productName'], 'Sản phẩm 1');
      expect(json['totalPrice'], 900000.0);
    });
  });
}
