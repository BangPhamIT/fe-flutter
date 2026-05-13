import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_form_cubit.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStockInRepository extends Mock implements StockInRepository {}

void main() {
  late StockInFormCubit cubit;
  late MockStockInRepository mockRepository;

  setUp(() {
    mockRepository = MockStockInRepository();
    cubit = StockInFormCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('StockInFormCubit', () {
    test('trạng thái ban đầu nên là StockInFormInitial', () {
      expect(cubit.state, isA<StockInFormInitial>());
    });

    blocTest<StockInFormCubit, StockInFormState>(
      'nên phát ra [StockInFormLoading, StockInFormSuccess] khi init thành công (tạo mới)',
      build: () {
        when(() => mockRepository.getWarehouses()).thenAnswer((_) async => []);
        when(() => mockRepository.getEmployees()).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.init(null),
      expect: () => [
        isA<StockInFormLoading>(),
        isA<StockInFormSuccess>(),
      ],
    );

    blocTest<StockInFormCubit, StockInFormState>(
      'nên phát ra [StockInFormSubmitting, StockInFormSubmitted] khi save thành công',
      build: () {
        when(() => mockRepository.createStockIn(any())).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.save({'receiptNumber': 'TEST-001'}),
      expect: () => [
        isA<StockInFormSubmitting>(),
        isA<StockInFormSubmitted>(),
      ],
    );

    blocTest<StockInFormCubit, StockInFormState>(
      'nên phát ra [StockInFormSubmitting, StockInFormFailure] khi save bị lỗi',
      build: () {
        when(() => mockRepository.createStockIn(any())).thenThrow(Exception('Save Error'));
        return cubit;
      },
      act: (cubit) => cubit.save({}),
      expect: () => [
        isA<StockInFormSubmitting>(),
        isA<StockInFormFailure>().having((s) => s.message, 'thông báo lỗi', contains('Save Error')),
      ],
    );
  });
}
