class ApiConstants {
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String prefixApi = '/api';
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  // Endpoints
  static const String stockInReceipt = '/stock-in-receipts';
  static const String warehouse = '/warehouses';
  static const String employee = '/employees';
}
