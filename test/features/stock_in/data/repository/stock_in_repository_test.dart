import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/features/stock_in/data/datasource/stock_in_client.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStockInClient extends Mock implements StockInClient {}

void main() {
  late StockInRepository repository;
  late MockStockInClient mockClient;

  setUp(() {
    mockClient = MockStockInClient();
    repository = StockInRepositoryImpl(mockClient);
  });

  group('StockInRepository Test', () {
    test('getStockInList nên gọi fetchList từ client với đúng tham số', () async {
      const mockResponse = {'elements': [], 'total': 0};
      when(() => mockClient.fetchList(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getStockInList(page: 2, limit: 20);

      expect(result, mockResponse);
      verify(() => mockClient.fetchList(page: 2, limit: 20)).called(1);
    });

    test('getStockInDetail nên trả về StockInReceipt từ client', () async {
      final mockReceipt = StockInReceipt(
        id: '1',
        receiptNumber: 'PNK001',
        receiptDate: DateTime.now(),
        totalAmount: 1000,
      );
      when(() => mockClient.fetchDetail(any()))
          .thenAnswer((_) async => mockReceipt);

      final result = await repository.getStockInDetail('1');

      expect(result, mockReceipt);
      verify(() => mockClient.fetchDetail('1')).called(1);
    });

    test('createStockIn nên gọi hàm create từ client', () async {
      final mockData = {'name': 'Test'};
      when(() => mockClient.create(any())).thenAnswer((_) async => {});

      await repository.createStockIn(mockData);

      verify(() => mockClient.create(mockData)).called(1);
    });
  });
}
