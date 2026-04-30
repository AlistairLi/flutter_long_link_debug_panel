import 'long_connection_command_log.dart';
import 'long_connection_error_log.dart';
import 'long_connection_status.dart';

/// 长连接调试面板的完整快照。
class LongConnectionDebugState {
  const LongConnectionDebugState({
    this.connectionStatus = LongConnectionStatus.disconnected,
    this.currentUrl = '',
    this.heartbeatStatus = LongConnectionHeartbeatStatus.idle,
    this.lastHeartbeatAt,
    this.reconnectCount = 0,
    this.commandLogs = const <LongConnectionCommandLog>[],
    this.errorLogs = const <LongConnectionErrorLog>[],
    this.extra = const <String, Object?>{},
    this.updatedAt,
  });

  /// 空状态，便于业务侧初始化 controller。
  factory LongConnectionDebugState.initial() {
    return LongConnectionDebugState(updatedAt: DateTime.now());
  }

  /// 当前连接状态。
  final LongConnectionStatus connectionStatus;

  /// 当前 WebSocket/TCP/MQTT 等长连地址。
  final String currentUrl;

  /// 心跳状态。
  final LongConnectionHeartbeatStatus heartbeatStatus;

  /// 最近一次心跳成功或心跳回包时间。
  final DateTime? lastHeartbeatAt;

  /// 当前会话累计重连次数。
  final int reconnectCount;

  /// 最近的指令日志，建议由 controller 控制最大条数。
  final List<LongConnectionCommandLog> commandLogs;

  /// 最近的错误日志，建议由 controller 控制最大条数。
  final List<LongConnectionErrorLog> errorLogs;

  /// 业务侧自定义扩展字段，库内不解析具体业务语义。
  final Map<String, Object?> extra;

  /// 状态最近更新时间。
  final DateTime? updatedAt;

  LongConnectionDebugState copyWith({
    LongConnectionStatus? connectionStatus,
    String? currentUrl,
    LongConnectionHeartbeatStatus? heartbeatStatus,
    DateTime? lastHeartbeatAt,
    int? reconnectCount,
    List<LongConnectionCommandLog>? commandLogs,
    List<LongConnectionErrorLog>? errorLogs,
    Map<String, Object?>? extra,
    DateTime? updatedAt,
  }) {
    return LongConnectionDebugState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentUrl: currentUrl ?? this.currentUrl,
      heartbeatStatus: heartbeatStatus ?? this.heartbeatStatus,
      lastHeartbeatAt: lastHeartbeatAt ?? this.lastHeartbeatAt,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      commandLogs: commandLogs ?? this.commandLogs,
      errorLogs: errorLogs ?? this.errorLogs,
      extra: extra ?? this.extra,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
