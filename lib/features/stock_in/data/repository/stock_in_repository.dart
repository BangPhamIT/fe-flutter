import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/data/models/warehouse.dart';
import 'package:inventory_app/data/models/employee.dart';
import '../datasource/stock_in_client.dart';

abstract class StockInRepository {
  Future<Map<String, dynamic>> getStockInList({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filter,
  });
  Future<StockInReceipt> getStockInDetail(String id);
  Future<void> createStockIn(Map<String, dynamic> data);
  Future<void> updateStockIn(String id, Map<String, dynamic> data);
  Future<void> deleteStockIn(String id);
  Future<List<Warehouse>> getWarehouses();
  Future<List<Employee>> getEmployees();
}

class StockInRepositoryImpl implements StockInRepository {
  final StockInClient _client;

  StockInRepositoryImpl(this._client);

  @override
  Future<Map<String, dynamic>> getStockInList({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filter,
  }) {
    return _client.fetchList(page: page, limit: limit, filter: filter);
  }

  @override
  Future<StockInReceipt> getStockInDetail(String id) {
    return _client.fetchDetail(id);
  }

  @override
  Future<void> createStockIn(Map<String, dynamic> data) {
    return _client.create(data);
  }

  @override
  Future<void> updateStockIn(String id, Map<String, dynamic> data) {
    return _client.update(id, data);
  }

  @override
  Future<void> deleteStockIn(String id) {
    return _client.delete(id);
  }

  @override
  Future<List<Warehouse>> getWarehouses() {
    return _client.fetchWarehouses();
  }

  @override
  Future<List<Employee>> getEmployees() {
    return _client.fetchEmployees();
  }
}
