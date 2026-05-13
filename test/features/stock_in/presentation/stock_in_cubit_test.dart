import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStockInRepository extends Mock implements StockInRepository {}

void main() {
  late StockInCubit cubit;
  late MockStockInRepository mockRepository;

  setUp(() {
    mockRepository = MockStockInRepository();
    cubit = StockInCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('StockInCubit', () {
    test('trạng thái ban đầu nên là StockInInitial', () {
      expect(cubit.state, isA<StockInInitial>());
    });

    blocTest<StockInCubit, StockInState>(
      'nên phát ra [StockInLoading, StockInSuccess] khi fetchList thành công',
      build: () {
        when(() => mockRepository.getStockInList(page: 1, limit: 10)).thenAnswer(
          (_) async => {
            'elements': [
              {'id': '1', 'receiptNumber': 'PNK-001'}
            ],
            'paginate': {'totalRecord': 1}
          },
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchList(),
      expect: () => [
        isA<StockInLoading>(),
        isA<StockInSuccess>().having((s) => s.receipts.length, 'số lượng receipts', 1),
      ],
    );

    blocTest<StockInCubit, StockInState>(
      'nên phát ra [StockInLoading, StockInFailure] khi fetchList bị lỗi',
      build: () {
        when(() => mockRepository.getStockInList(page: 1, limit: 10))
            .thenThrow(Exception('API Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchList(),
      expect: () => [
        isA<StockInLoading>(),
        isA<StockInFailure>().having((s) => s.message, 'thông báo lỗi', contains('API Error')),
      ],
    );

    blocTest<StockInCubit, StockInState>(
      'nên phát ra trạng thái isLoadingMore khi fetchMoreList',
      build: () {
        when(() => mockRepository.getStockInList(page: 2, limit: 10)).thenAnswer(
          (_) async => {
            'elements': [
              {'id': '2', 'receiptNumber': 'PNK-002'}
            ],
            'paginate': {'totalRecord': 2}
          },
        );
        // Set initial success state
        return cubit;
      },
      seed: () => const StockInSuccess(
        receipts: [],
        total: 2,
        page: 1,
        hasMore: true,
      ),
      act: (cubit) => cubit.fetchMoreList(),
      expect: () => [
        isA<StockInSuccess>().having((s) => s.isLoadingMore, 'đang tải thêm', true),
        isA<StockInSuccess>().having((s) => s.receipts.length, 'số lượng receipts', 1),
      ],
    );
  });
}
