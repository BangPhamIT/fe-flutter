import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String id;
  final String warehouseCode;
  final String name;
  final String? location;

  const Warehouse({
    required this.id,
    required this.warehouseCode,
    required this.name,
    this.location,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        id: json['id'] as String,
        warehouseCode: json['warehouseCode'] as String? ?? '',
        name: json['name'] as String? ?? '',
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'warehouseCode': warehouseCode,
        'name': name,
        'location': location,
      };

  @override
  List<Object?> get props => [id, warehouseCode, name, location];
}
