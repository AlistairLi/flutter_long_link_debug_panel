import 'long_connection_status.dart';

/// 长连接错误日志。
class LongConnectionErrorLog {
  const LongConnectionErrorLog({
    required this.message,
    this.detail,
    this.stackTrace,
    this.timestamp,
    this.level = LongConnectionErrorLevel.error,
  });

  /// 错误摘要。
  final String message;

  /// 错误详情，例如异常对象、服务端错误码或补充上下文。
  final Object? detail;

  /// 堆栈信息，建议业务侧只在开发和测试环境传入。
  final Object? stackTrace;

  /// 发生时间，不传时由 controller 自动补齐。
  final DateTime? timestamp;

  /// 日志级别。
  final LongConnectionErrorLevel level;

  LongConnectionErrorLog copyWith({
    String? message,
    Object? detail,
    Object? stackTrace,
    DateTime? timestamp,
    LongConnectionErrorLevel? level,
  }) {
    return LongConnectionErrorLog(
      message: message ?? this.message,
      detail: detail ?? this.detail,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
    );
  }
}
