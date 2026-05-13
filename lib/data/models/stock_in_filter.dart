import 'package:equatable/equatable.dart';

class StockInFilter extends Equatable {
  final String? receiptNumber;
  final String? warehouseId;
  final DateTime? startDate;
  final DateTime? endDate;

  const StockInFilter({
    this.receiptNumber,
    this.warehouseId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (receiptNumber != null && receiptNumber!.isNotEmpty) 'receiptNumber': receiptNumber,
      if (warehouseId != null && warehouseId!.isNotEmpty) 'warehouseId': warehouseId,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }

  StockInFilter copyWith({
    String? receiptNumber,
    String? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StockInFilter(
      receiptNumber: receiptNumber ?? this.receiptNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [receiptNumber, warehouseId, startDate, endDate];
}
