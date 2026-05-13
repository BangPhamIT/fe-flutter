import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:inventory_app/features/stock_in/presentation/screens/stock_in_list_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockStockInCubit extends Mock implements StockInCubit {}

void main() {
  late MockStockInCubit mockCubit;
  late StreamController<StockInState> stateController;

  setUp(() {
    mockCubit = MockStockInCubit();
    stateController = StreamController<StockInState>.broadcast();
    
    // Stub stream và state
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.state).thenReturn(StockInInitial());
    
    // Stub fetchList cực kỳ chi tiết để không bị trượt call
    when(() => mockCubit.fetchList(limit: any(named: 'limit')))
        .thenAnswer((_) => Future<void>.value());
    when(() => mockCubit.fetchList())
        .thenAnswer((_) => Future<void>.value());
        
    when(() => mockCubit.fetchMoreList(limit: any(named: 'limit')))
        .thenAnswer((_) => Future<void>.value());
        
    when(() => mockCubit.close()).thenAnswer((_) => Future<void>.value());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<StockInCubit>.value(
            value: mockCubit,
            child: const StockInListScreen(),
          ),
        );
      },
    );
  }

  group('StockInListScreen Widget Test', () {
    testWidgets('nên hiển thị CircularProgressIndicator khi ở trạng thái Loading', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockCubit.state).thenReturn(StockInLoading());
      stateController.add(StockInLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Đảm bảo UI cập nhật sau initState

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('nên hiển thị thông báo "Chưa có dữ liệu" khi danh sách trống', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const emptyState = StockInSuccess(
        receipts: [],
        total: 0,
        page: 1,
        hasMore: false,
      );
      when(() => mockCubit.state).thenReturn(emptyState);
      stateController.add(emptyState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Chưa có dữ liệu'), findsOneWidget);
    });

    testWidgets('nên hiển thị danh sách các Card khi tải dữ liệu thành công', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockReceipts = [
        StockInReceipt(
          id: '1',
          receiptNumber: 'PNK-2024-001',
          receiptDate: DateTime.now(),
          totalAmount: 1000000,
        ),
      ];

      final successState = StockInSuccess(
        receipts: mockReceipts,
        total: 1,
        page: 1,
        hasMore: false,
      );
      
      when(() => mockCubit.state).thenReturn(successState);
      stateController.add(successState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('PNK-2024-001'), findsOneWidget);
    });

    testWidgets('nên hiển thị lỗi và nút "Thử lại" khi tải thất bại', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const errorState = StockInFailure('Lỗi kết nối');
      when(() => mockCubit.state).thenReturn(errorState);
      stateController.add(errorState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Lỗi: Lỗi kết nối'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Thử lại'), findsOneWidget);
    });
  });
}
