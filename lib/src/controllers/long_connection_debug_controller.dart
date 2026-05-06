import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// 业务项目通过这个 controller 把长连接状态写入调试面板。
class LongConnectionDebugController
    extends ValueNotifier<LongConnectionDebugState> {
  LongConnectionDebugController({
    LongConnectionDebugState? initialState,
    this.maxCommandLogCount = 100,
    this.maxErrorLogCount = 50,
  }) : super(initialState ?? LongConnectionDebugState.initial());

  /// 面板保留的最大指令数量。
  final int maxCommandLogCount;

  /// 面板保留的最大错误数量。
  final int maxErrorLogCount;

  /// 直接替换整份状态，适合业务侧已有聚合状态的场景。
  void setState(LongConnectionDebugState state) {
    value = state.copyWith(updatedAt: DateTime.now());
  }

  /// 更新连接状态和地址。
  void updateConnection({
    LongConnectionStatus? status,
    String? currentUrl,
    DateTime? nextReconnectAt,
    bool clearNextReconnectAt = false,
    String? currentRoomId,
    int? reconnectCount,
    Map<String, Object?>? extra,
  }) {
    value = value.copyWith(
      connectionStatus: status,
      currentUrl: currentUrl,
      nextReconnectAt: clearNextReconnectAt
          ? null
          : nextReconnectAt ?? value.nextReconnectAt,
      currentRoomId: currentRoomId,
      reconnectCount: reconnectCount,
      extra: extra,
      updatedAt: DateTime.now(),
    );
  }

  /// 更新心跳状态。
  void updateHeartbeat({
    LongConnectionHeartbeatStatus? status,
    DateTime? lastHeartbeatAt,
    String? currentRoomId,
  }) {
    value = value.copyWith(
      heartbeatStatus: status,
      lastHeartbeatAt: lastHeartbeatAt,
      currentRoomId: currentRoomId,
      updatedAt: DateTime.now(),
    );
  }

  /// 重连次数加一。
  void increaseReconnectCount() {
    value = value.copyWith(
      reconnectCount: value.reconnectCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// 添加一条指令日志。
  void addCommand(LongConnectionCommandLog log) {
    final normalizedLog = log.timestamp == null
        ? log.copyWith(timestamp: DateTime.now())
        : log;
    value = value.copyWith(
      commandLogs: _limited(<LongConnectionCommandLog>[
        normalizedLog,
        ...value.commandLogs,
      ], maxCommandLogCount),
      updatedAt: DateTime.now(),
    );
  }

  /// 添加一条错误日志。
  void addError(LongConnectionErrorLog log) {
    final normalizedLog = log.timestamp == null
        ? log.copyWith(timestamp: DateTime.now())
        : log;
    value = value.copyWith(
      errorLogs: _limited(<LongConnectionErrorLog>[
        normalizedLog,
        ...value.errorLogs,
      ], maxErrorLogCount),
      updatedAt: DateTime.now(),
    );
  }

  /// 清空指令日志。
  void clearCommands() {
    value = value.copyWith(
      commandLogs: const <LongConnectionCommandLog>[],
      updatedAt: DateTime.now(),
    );
  }

  /// 清空错误日志。
  void clearErrors() {
    value = value.copyWith(
      errorLogs: const <LongConnectionErrorLog>[],
      updatedAt: DateTime.now(),
    );
  }

  /// 重置为初始状态。
  void reset() {
    value = LongConnectionDebugState.initial();
  }

  List<T> _limited<T>(List<T> logs, int maxCount) {
    if (maxCount <= 0) {
      return <T>[];
    }
    if (logs.length <= maxCount) {
      return List<T>.unmodifiable(logs);
    }
    return List<T>.unmodifiable(logs.take(maxCount));
  }
}
