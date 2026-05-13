import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/data/models/warehouse.dart';
import 'package:inventory_app/data/models/employee.dart';

void main() {
  group('StockInReceipt Model', () {
    final testJson = {
      'id': '1',
      'receiptNumber': 'PNK-001',
      'receiptDate': '2026-05-12T10:00:00.000Z',
      'totalAmount': 1500000.0,
      'companyName': 'Công ty A',
      'warehouse': {
        'id': 'w1',
        'name': 'Kho Tổng',
      },
      'receiver': {
        'id': 'e1',
        'fullName': 'Nguyễn Văn A',
      }
    };

    test('nên parse từ JSON đúng cấu trúc', () {
      final receipt = StockInReceipt.fromJson(testJson);

      expect(receipt.id, '1');
      expect(receipt.receiptNumber, 'PNK-001');
      expect(receipt.totalAmount, 1500000.0);
      expect(receipt.companyName, 'Công ty A');
      expect(receipt.warehouse, isA<Warehouse>());
      expect(receipt.warehouse?.name, 'Kho Tổng');
      expect(receipt.receiver, isA<Employee>());
      expect(receipt.receiver?.fullName, 'Nguyễn Văn A');
    });

    test('nên chuyển đổi sang JSON đúng cấu trúc', () {
      final receipt = StockInReceipt.fromJson(testJson);
      final json = receipt.toJson();

      expect(json['id'], '1');
      expect(json['receiptNumber'], 'PNK-001');
      expect(json['totalAmount'], 1500000.0);
    });

    test('nên xử lý dữ liệu thiếu (null) một cách an toàn', () {
      final minimalJson = {
        'id': '2',
        'receiptNumber': 'PNK-002',
      };

      final receipt = StockInReceipt.fromJson(minimalJson);

      expect(receipt.id, '2');
      expect(receipt.companyName, isNull);
      expect(receipt.warehouse, isNull);
      expect(receipt.totalAmount, 0.0);
    });
  });
}
