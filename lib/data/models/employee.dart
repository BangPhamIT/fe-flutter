import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String employeeCode;
  final String fullName;
  final String? department;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String,
        employeeCode: json['employeeCode'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        department: json['department'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeCode': employeeCode,
        'fullName': fullName,
        'department': department,
      };

  @override
  List<Object?> get props => [id, employeeCode, fullName, department];
}
