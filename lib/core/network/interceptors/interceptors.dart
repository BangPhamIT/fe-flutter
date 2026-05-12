import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'logger_interceptor.dart';

class InterceptorBuilder {
  InterceptorBuilder._();

  static Interceptor get logger {
    if (kDebugMode) {
      return LoggerInterceptor.loggerInterceptor();
    } else {
      return Interceptor();
    }
  }
}
