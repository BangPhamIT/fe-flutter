import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_form_cubit.dart';
import 'package:inventory_app/features/stock_in/presentation/screens/stock_in_form_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockStockInFormCubit extends Mock implements StockInFormCubit {}

void main() {
  late MockStockInFormCubit mockCubit;
  late StreamController<StockInFormState> stateController;

  setUp(() {
    mockCubit = MockStockInFormCubit();
    stateController = StreamController<StockInFormState>.broadcast();
    
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.state).thenReturn(StockInFormInitial());
    
    // Stub init method
    when(() => mockCubit.init(any())).thenAnswer((_) => Future<void>.value());
    when(() => mockCubit.close()).thenAnswer((_) => Future<void>.value());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<StockInFormCubit>.value(
            value: mockCubit,
            child: const StockInFormScreen(),
          ),
        );
      },
    );
  }

  group('StockInFormScreen Widget Test', () {
    testWidgets('nên hiển thị Loading khi trạng thái là StockInFormLoading', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockCubit.state).thenReturn(StockInFormLoading());
      stateController.add(StockInFormLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('nên hiển thị các trường nhập liệu khi trạng thái là StockInFormSuccess', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final successState = StockInFormSuccess(
        warehouses: [],
        employees: [],
      );
      
      when(() => mockCubit.state).thenReturn(successState);
      stateController.add(successState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Thông tin chung'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('nên hiển thị SnackBar lỗi khi trạng thái là StockInFormFailure', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const errorState = StockInFormFailure('Lỗi không xác định');
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Đẩy trạng thái lỗi vào stream
      stateController.add(errorState);
      
      // Pump để listener nhận trạng thái và hiển thị SnackBar
      await tester.pump(); 

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Lỗi: Lỗi không xác định'), findsOneWidget);
    });
  });
}
