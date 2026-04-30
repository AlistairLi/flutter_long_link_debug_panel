/// 长连接指令收发日志。
class LongConnectionCommandLog {
  const LongConnectionCommandLog({
    required this.type,
    required this.rawData,
    this.parsedResult,
    this.id,
    this.timestamp,
    this.isIncoming = true,
  });

  /// 业务侧可传入消息 ID，便于排查重复包或乱序。
  final String? id;

  /// 指令类型，例如 room.join、im.message、heartbeat.pong。
  final String type;

  /// 指令原始数据，可以是 String、Map、List 或业务自定义对象。
  final Object? rawData;

  /// 指令解析结果，可以传入解析后的 DTO、Map 或错误说明。
  final Object? parsedResult;

  /// 指令收发时间，不传时由 controller 自动补齐。
  final DateTime? timestamp;

  /// true 表示收到服务端指令，false 表示客户端发出指令。
  final bool isIncoming;

  LongConnectionCommandLog copyWith({
    String? id,
    String? type,
    Object? rawData,
    Object? parsedResult,
    DateTime? timestamp,
    bool? isIncoming,
  }) {
    return LongConnectionCommandLog(
      id: id ?? this.id,
      type: type ?? this.type,
      rawData: rawData ?? this.rawData,
      parsedResult: parsedResult ?? this.parsedResult,
      timestamp: timestamp ?? this.timestamp,
      isIncoming: isIncoming ?? this.isIncoming,
    );
  }
}
