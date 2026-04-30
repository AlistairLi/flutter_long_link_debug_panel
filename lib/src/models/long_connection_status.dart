/// 长连接的连接状态。
enum LongConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// 心跳检测状态。
enum LongConnectionHeartbeatStatus { idle, healthy, timeout, failed }

/// 错误日志级别。
enum LongConnectionErrorLevel { info, warning, error }

extension LongConnectionStatusText on LongConnectionStatus {
  /// 面板中展示的中文状态文案。
  String get label {
    switch (this) {
      case LongConnectionStatus.disconnected:
        return '未连接';
      case LongConnectionStatus.connecting:
        return '连接中';
      case LongConnectionStatus.connected:
        return '已连接';
      case LongConnectionStatus.reconnecting:
        return '重连中';
      case LongConnectionStatus.failed:
        return '连接失败';
    }
  }
}

extension LongConnectionHeartbeatStatusText on LongConnectionHeartbeatStatus {
  /// 面板中展示的中文心跳文案。
  String get label {
    switch (this) {
      case LongConnectionHeartbeatStatus.idle:
        return '未开始';
      case LongConnectionHeartbeatStatus.healthy:
        return '正常';
      case LongConnectionHeartbeatStatus.timeout:
        return '超时';
      case LongConnectionHeartbeatStatus.failed:
        return '异常';
    }
  }
}
