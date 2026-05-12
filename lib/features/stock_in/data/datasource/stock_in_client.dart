import 'package:inventory_app/core/network/client_provider.dart';
import 'package:inventory_app/core/network/dio_options_builder.dart';
import 'package:inventory_app/core/network/dio_typedef_define.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/data/models/warehouse.dart';
import 'package:inventory_app/data/models/employee.dart';
import 'stock_in_target.dart';

import 'package:inventory_app/core/network/interceptors/interceptors.dart';

class StockInClient extends DioClientProvider {
  StockInClient({required String baseUrl}) {
    dio = DioNetWork(DioOptionsBuilder.options(baseUrl: baseUrl));
    dio.interceptors.add(InterceptorBuilder.logger);
  }

  Future<Map<String, dynamic>> fetchList({int page = 1, int limit = 10}) async {
    final response = await requestData(StockInTarget.getList(page: page, limit: limit));
    return response as Map<String, dynamic>;
  }

  Future<StockInReceipt> fetchDetail(String id) async {
    final data = await requestData(StockInTarget.getDetail(id));
    return StockInReceipt.fromJson(data as Map<String, dynamic>);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await requestData(StockInTarget.create(data));
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await requestData(StockInTarget.update(id, data));
  }

  Future<void> delete(String id) async {
    await requestData(StockInTarget.delete(id));
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final data = await requestData(StockInTarget.getWarehouses());
    // Nếu data là object chứa elements hoặc là list trực tiếp
    final list = (data is Map ? data['elements'] : data) as List? ?? [];
    return list.map((e) => Warehouse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Employee>> fetchEmployees() async {
    final data = await requestData(StockInTarget.getEmployees());
    final list = (data is Map ? data['elements'] : data) as List? ?? [];
    return list.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
  }
}
