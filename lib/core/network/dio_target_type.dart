import 'dio_typedef_define.dart';

class DioTargetType {
  final String path;
  final dynamic data;
  final DioFormData? formData;
  final Map<String, dynamic>? queryParameters;
  final DioOptions? options;

  DioTargetType({
    required this.path,
    this.data,
    this.formData,
    this.queryParameters,
    this.options,
  });
}
