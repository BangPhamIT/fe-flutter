import 'package:equatable/equatable.dart';
import 'warehouse.dart';
import 'stock_in_item.dart';
import 'employee.dart';

class StockInReceipt extends Equatable {
  final String id;
  final String receiptNumber;
  final DateTime receiptDate;
  final String? companyName;
  final String? departmentName;
  final String? debtAccount;
  final String? creditAccount;
  final String? delivererName;
  final String? creatorId;
  final String? receiverId;
  final String? warehouseKeeperId;
  final String? chiefAccountantId;
  final String? warehouseId;
  final String? note;
  final Warehouse? warehouse;
  final Employee? receiver;
  final Employee? creator;
  final Employee? warehouseKeeper;
  final Employee? chiefAccountant;
  final double totalAmount;
  final List<StockInItem>? items;

  const StockInReceipt({
    required this.id,
    required this.receiptNumber,
    required this.receiptDate,
    this.companyName,
    this.departmentName,
    this.debtAccount,
    this.creditAccount,
    this.delivererName,
    this.creatorId,
    this.receiverId,
    this.warehouseKeeperId,
    this.chiefAccountantId,
    this.warehouseId,
    this.note,
    this.warehouse,
    this.receiver,
    this.creator,
    this.warehouseKeeper,
    this.chiefAccountant,
    required this.totalAmount,
    this.items,
  });

  factory StockInReceipt.fromJson(Map<String, dynamic> json) => StockInReceipt(
        id: json['id'] as String,
        receiptNumber: json['receiptNumber'] as String? ?? '',
        receiptDate: json['receiptDate'] != null
            ? DateTime.parse(json['receiptDate'] as String)
            : DateTime.now(),
        companyName: json['companyName'] as String?,
        departmentName: json['departmentName'] as String?,
        debtAccount: json['debtAccount'] as String?,
        creditAccount: json['creditAccount'] as String?,
        delivererName: json['delivererName'] as String?,
        creatorId: json['creatorId'] as String?,
        receiverId: json['receiverId'] as String?,
        warehouseKeeperId: json['warehouseKeeperId'] as String?,
        chiefAccountantId: json['chiefAccountantId'] as String?,
        warehouseId: json['warehouseId'] as String?,
        note: json['note'] as String?,
        warehouse: json['warehouse'] != null
            ? Warehouse.fromJson(json['warehouse'] as Map<String, dynamic>)
            : null,
        receiver: json['receiver'] != null
            ? Employee.fromJson(json['receiver'] as Map<String, dynamic>)
            : null,
        creator: json['creator'] != null
            ? Employee.fromJson(json['creator'] as Map<String, dynamic>)
            : null,
        warehouseKeeper: json['warehouseKeeper'] != null
            ? Employee.fromJson(json['warehouseKeeper'] as Map<String, dynamic>)
            : null,
        chiefAccountant: json['chiefAccountant'] != null
            ? Employee.fromJson(json['chiefAccountant'] as Map<String, dynamic>)
            : null,
        totalAmount:
            double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => StockInItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'receiptNumber': receiptNumber,
        'receiptDate': receiptDate.toIso8601String(),
        'companyName': companyName,
        'departmentName': departmentName,
        'debtAccount': debtAccount,
        'creditAccount': creditAccount,
        'delivererName': delivererName,
        'creatorId': creatorId,
        'receiverId': receiverId,
        'warehouseKeeperId': warehouseKeeperId,
        'chiefAccountantId': chiefAccountantId,
        'warehouseId': warehouseId,
        'note': note,
        'totalAmount': totalAmount,
        'items': items?.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        receiptNumber,
        receiptDate,
        companyName,
        departmentName,
        debtAccount,
        creditAccount,
        delivererName,
        creatorId,
        receiverId,
        warehouseKeeperId,
        chiefAccountantId,
        warehouseId,
        note,
        warehouse,
        receiver,
        creator,
        warehouseKeeper,
        chiefAccountant,
        totalAmount,
        items,
      ];
}
