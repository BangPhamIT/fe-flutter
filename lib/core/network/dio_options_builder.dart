import 'dio_typedef_define.dart';

class DioOptionsBuilder {
  static DioBaseOptions options({
    required String baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
  }) {
    return DioBaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      contentType: 'application/json',
    );
  }

  static DioOptions request({
    String? method,
    Map<String, dynamic>? headers,
  }) {
    return DioOptions(
      method: method,
      headers: headers,
    );
  }
}
