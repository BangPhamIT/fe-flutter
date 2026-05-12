import 'package:equatable/equatable.dart';

class StockInItem extends Equatable {
  final String? id;
  final String? productCode;
  final String productName;
  final String? unit;
  final double quantityDocument;
  final double quantityActual;
  final double unitPrice;
  final double totalPrice;

  const StockInItem({
    this.id,
    this.productCode,
    required this.productName,
    this.unit,
    required this.quantityDocument,
    required this.quantityActual,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory StockInItem.fromJson(Map<String, dynamic> json) => StockInItem(
        id: json['id'] as String?,
        productCode: json['productCode'] as String?,
        productName: json['productName'] as String? ?? '',
        unit: json['unit'] as String?,
        quantityDocument: double.tryParse(json['quantityDocument']?.toString() ?? '0') ?? 0.0,
        quantityActual: double.tryParse(json['quantityActual']?.toString() ?? '0') ?? 0.0,
        unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
        totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productCode': productCode,
        'productName': productName,
        'unit': unit,
        'quantityDocument': quantityDocument,
        'quantityActual': quantityActual,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  @override
  List<Object?> get props => [
        id,
        productCode,
        productName,
        unit,
        quantityDocument,
        quantityActual,
        unitPrice,
        totalPrice,
      ];
}
