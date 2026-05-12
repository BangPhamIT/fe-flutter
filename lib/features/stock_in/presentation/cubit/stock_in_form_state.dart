part of 'stock_in_form_cubit.dart';

abstract class StockInFormState extends Equatable {
  const StockInFormState();
  @override
  List<Object?> get props => [];
}

class StockInFormInitial extends StockInFormState {}
class StockInFormLoading extends StockInFormState {}
class StockInFormSubmitting extends StockInFormState {}
class StockInFormSubmitted extends StockInFormState {}
class StockInFormSuccess extends StockInFormState {
  final List<Warehouse> warehouses;
  final List<Employee> employees;
  final StockInReceipt? receipt;

  const StockInFormSuccess({
    required this.warehouses,
    required this.employees,
    this.receipt,
  });

  @override
  List<Object?> get props => [warehouses, employees, receipt];
}
class StockInFormFailure extends StockInFormState {
  final String message;
  const StockInFormFailure(this.message);
  @override
  List<Object?> get props => [message];
}
