import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_app/core/theme/themes.dart';
import 'package:inventory_app/dependency/injection.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_form_cubit.dart';
import 'package:inventory_app/features/stock_in/presentation/screens/stock_in_list_screen.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => StockInCubit(repository: getIt<StockInRepository>()),
            ),
            BlocProvider(
              create: (context) => StockInFormCubit(repository: getIt<StockInRepository>()),
            ),
          ],
          child: MaterialApp(
            title: 'Inventory App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              scaffoldBackgroundColor: AppColors.background,
              inputDecorationTheme: InputDecorationTheme(
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            home: const StockInListScreen(),
          ),
        );
      },
    );
  }
}
