import 'long_connection_command_log.dart';
import 'long_connection_error_log.dart';
import 'long_connection_status.dart';

const Object _unset = Object();

/// 长连接调试面板的完整快照。
class LongConnectionDebugState {
  const LongConnectionDebugState({
    this.connectionStatus = LongConnectionStatus.disconnected,
    this.currentUrl = '',
    this.nextReconnectAt,
    this.currentRoomId = '',
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

  /// 下一次自动重连时间。
  final DateTime? nextReconnectAt;

  /// 当前房间 ID，心跳状态通常和房间关联。
  final String currentRoomId;

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
    Object? nextReconnectAt = _unset,
    String? currentRoomId,
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
      nextReconnectAt: identical(nextReconnectAt, _unset)
          ? this.nextReconnectAt
          : nextReconnectAt as DateTime?,
      currentRoomId: currentRoomId ?? this.currentRoomId,
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
