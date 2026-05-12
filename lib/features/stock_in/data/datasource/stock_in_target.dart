import 'package:inventory_app/core/constants/api_constants.dart';
import 'package:inventory_app/core/network/dio_options_builder.dart';
import 'package:inventory_app/core/network/dio_target_type.dart';

class StockInTarget {
  static DioTargetType getList({int page = 1, int limit = 10}) {
    return DioTargetType(
      path: ApiConstants.stockInReceipt,
      queryParameters: {'page': page, 'limit': limit},
      options: DioOptionsBuilder.request(method: 'GET'),
    );
  }

  static DioTargetType getDetail(String id) {
    return DioTargetType(
      path: '${ApiConstants.stockInReceipt}/$id',
      options: DioOptionsBuilder.request(method: 'GET'),
    );
  }

  static DioTargetType create(Map<String, dynamic> data) {
    return DioTargetType(
      path: ApiConstants.stockInReceipt,
      data: data,
      options: DioOptionsBuilder.request(method: 'POST'),
    );
  }

  static DioTargetType update(String id, Map<String, dynamic> data) {
    return DioTargetType(
      path: '${ApiConstants.stockInReceipt}/$id',
      data: data,
      options: DioOptionsBuilder.request(method: 'PUT'),
    );
  }

  static DioTargetType delete(String id) {
    return DioTargetType(
      path: '${ApiConstants.stockInReceipt}/$id',
      options: DioOptionsBuilder.request(method: 'DELETE'),
    );
  }

  static DioTargetType getWarehouses() {
    return DioTargetType(
      path: ApiConstants.warehouse,
      options: DioOptionsBuilder.request(method: 'GET'),
    );
  }

  static DioTargetType getEmployees() {
    return DioTargetType(
      path: ApiConstants.employee,
      options: DioOptionsBuilder.request(method: 'GET'),
    );
  }
}
