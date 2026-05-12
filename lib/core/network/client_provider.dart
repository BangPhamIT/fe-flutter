import 'dio_target_type.dart';
import 'dio_typedef_define.dart';

abstract class DioClientProvider {
  late final DioNetWork dio;

  Future<DioResponse> request(
    DioTargetType target, {
    DioCancelToken? cancelToken,
    DioProgressCallback? onSendProgress,
    DioProgressCallback? onReceiveProgress,
  }) async {
    return dio.request(
      target.path,
      data: target.data ?? target.formData,
      options: target.options,
      queryParameters: target.queryParameters,
      cancelToken: cancelToken,
    );
  }

  Future<dynamic> requestData(
    DioTargetType target, {
    String? atKey,
    DioCancelToken? cancelToken,
    DioProgressCallback? onSendProgress,
    DioProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await request(
        target,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      if (atKey != null) {
        final map = response.data;
        if (map is Map<String, dynamic>) {
          return map[atKey];
        }
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
