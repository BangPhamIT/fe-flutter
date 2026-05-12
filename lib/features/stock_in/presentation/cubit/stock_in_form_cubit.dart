import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/data/models/warehouse.dart';
import 'package:inventory_app/data/models/employee.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';

part 'stock_in_form_state.dart';

class StockInFormCubit extends Cubit<StockInFormState> {
  final StockInRepository repository;

  StockInFormCubit({required this.repository}) : super(StockInFormInitial());

  Future<void> init(String? id) async {
    emit(StockInFormLoading());
    try {
      final warehouses = await repository.getWarehouses();
      final employees = await repository.getEmployees();
      
      if (id != null) {
        final receipt = await repository.getStockInDetail(id);
        emit(StockInFormSuccess(
          warehouses: warehouses,
          employees: employees,
          receipt: receipt,
        ));
      } else {
        emit(StockInFormSuccess(
          warehouses: warehouses,
          employees: employees,
        ));
      }
    } catch (e) {
      emit(StockInFormFailure(e.toString()));
    }
  }

  Future<void> save(Map<String, dynamic> data, {String? id}) async {
    emit(StockInFormSubmitting());
    try {
      if (id != null) {
        await repository.updateStockIn(id, data);
      } else {
        await repository.createStockIn(data);
      }
      emit(StockInFormSubmitted());
    } catch (e) {
      emit(StockInFormFailure(e.toString()));
    }
  }
}
