import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_long_link_debug_panel/flutter_long_link_debug_panel.dart';

void main() => runApp(const IntegrationExampleApp());

/// App 接入方式示例。
///
/// - App 侧持有全局 debug controller。
/// - 非正式环境开启，正式环境关闭统计和展示。
/// - 长连 manager 在连接、断开、重连、心跳、收到消息时写入调试面板。
/// - 设置页提供完整调试页面入口，页面内可以显示悬浮窗。
class IntegrationExampleApp extends StatefulWidget {
  const IntegrationExampleApp({super.key});

  @override
  State<IntegrationExampleApp> createState() =>
      _IntegrationExampleAppState();
}

class _IntegrationExampleAppState extends State<IntegrationExampleApp> {
  final _longLinkManager = MockLongLinkManager();

  @override
  void initState() {
    super.initState();
    LongLinkDebugExampleService.setEnabled(!_isProdEnv);
    _longLinkManager.startNewConnect();
  }

  @override
  void dispose() {
    _longLinkManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Integration Example')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ListTile(
              title: const Text('Long Link Debug'),
              subtitle: const Text('Open debug page used by settings page'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LongConnectionDebugPage(
                      controller: LongLinkDebugExampleService.controller,
                      enabled: LongLinkDebugExampleService.enabled,
                      onConnect: _longLinkManager.startNewConnect,
                      onDisconnect:
                          _longLinkManager.disconnectCurrentConnection,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Mock join room'),
              subtitle: const Text('Start room heartbeat and set roomId'),
              onTap: () => _longLinkManager.joinRoom('8888'),
            ),
            ListTile(
              title: const Text('Mock incoming command'),
              subtitle: const Text('Add one long-link command log'),
              onTap: _longLinkManager.mockIncomingMessage,
            ),
            ListTile(
              title: const Text('Mock connection error'),
              subtitle: const Text('Show failed state and next reconnect time'),
              onTap: _longLinkManager.mockConnectionError,
            ),
          ],
        ),
      ),
    );
  }
}

const bool _isProdEnv = bool.fromEnvironment('PROD', defaultValue: false);

class LongLinkDebugExampleService {
  LongLinkDebugExampleService._();

  static final LongConnectionDebugController controller =
      LongConnectionDebugController();

  static bool _enabled = false;
  static int _messageCount = 0;
  static int _inboundBytes = 0;
  static String _currentChannel = '';
  static String _currentRoomId = '';

  static bool get enabled => _enabled;

  static void setEnabled(bool enabled) {
    if (_enabled == enabled) {
      return;
    }
    _enabled = enabled;
    if (!enabled) {
      LongConnectionDebugOverlayController.hide();
      _messageCount = 0;
      _inboundBytes = 0;
      _currentChannel = '';
      _currentRoomId = '';
      controller.reset();
    }
  }

  static void updateConnection({
    LongConnectionStatus? status,
    String? currentUrl,
    DateTime? nextReconnectAt,
    bool clearNextReconnectAt = false,
    int? reconnectCount,
    String? roomId,
  }) {
    if (!_enabled) {
      return;
    }
    if (roomId != null) {
      _currentRoomId = roomId;
    }
    controller.updateConnection(
      status: status,
      currentUrl: currentUrl,
      nextReconnectAt: nextReconnectAt,
      clearNextReconnectAt: clearNextReconnectAt,
      currentRoomId: _currentRoomId,
      reconnectCount: reconnectCount,
      extra: <String, Object?>{
        'messageCount': _messageCount,
        'inboundBytes': _inboundBytes,
        if (_currentChannel.isNotEmpty) 'lastChannel': _currentChannel,
      },
    );
  }

  static void updateHeartbeat({
    required LongConnectionHeartbeatStatus status,
    DateTime? lastHeartbeatAt,
    String? roomId,
  }) {
    if (!_enabled) {
      return;
    }
    if (roomId != null) {
      _currentRoomId = roomId;
    }
    controller.updateHeartbeat(
      status: status,
      lastHeartbeatAt: lastHeartbeatAt,
      currentRoomId: _currentRoomId,
    );
  }

  static void recordIncomingMessage({
    required String channel,
    required int bytes,
    required Map<String, Object?> payload,
  }) {
    if (!_enabled) {
      return;
    }
    _messageCount += 1;
    _inboundBytes += bytes;
    _currentChannel = channel;
    controller.addCommand(
      LongConnectionCommandLog(
        id: payload['msgId']?.toString(),
        type: payload['event']?.toString() ?? channel,
        rawData: <String, Object?>{
          'channel': channel,
          'bytes': bytes,
          'payload': payload,
        },
        parsedResult: payload['payload'],
      ),
    );
    updateConnection();
  }

  static void recordError(String message, {Object? detail}) {
    if (!_enabled) {
      return;
    }
    controller.addError(
      LongConnectionErrorLog(message: message, detail: detail),
    );
  }
}

class MockLongLinkManager {
  static const _url = 'wss://www.example.com/connection/websocket';

  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  int _retryTime = 0;
  String _roomId = '';

  void startNewConnect() {
    _retryTimer?.cancel();
    LongLinkDebugExampleService.updateConnection(
      status: _retryTime > 0
          ? LongConnectionStatus.reconnecting
          : LongConnectionStatus.connecting,
      currentUrl: _url,
      clearNextReconnectAt: true,
      reconnectCount: _retryTime,
      roomId: _roomId,
    );

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      _retryTime = 0;
      LongLinkDebugExampleService.updateConnection(
        status: LongConnectionStatus.connected,
        currentUrl: _url,
        clearNextReconnectAt: true,
        reconnectCount: _retryTime,
        roomId: _roomId,
      );
    });
  }

  void disconnectCurrentConnection() {
    _retryTimer?.cancel();
    _heartbeatTimer?.cancel();
    LongLinkDebugExampleService.updateConnection(
      status: LongConnectionStatus.disconnected,
      clearNextReconnectAt: true,
      roomId: _roomId,
    );
    LongLinkDebugExampleService.updateHeartbeat(
      status: LongConnectionHeartbeatStatus.idle,
      roomId: '',
    );
  }

  void mockConnectionError() {
    _retryTime += 1;
    final delay = Duration(seconds: _retryTime == 1 ? 2 : 4);
    LongLinkDebugExampleService.updateConnection(
      status: LongConnectionStatus.failed,
      nextReconnectAt: DateTime.now().add(delay),
      reconnectCount: _retryTime,
      roomId: _roomId,
    );
    LongLinkDebugExampleService.recordError(
      'LongLink error',
      detail: <String, Object?>{'retryTime': _retryTime},
    );
    _retryTimer = Timer(delay, startNewConnect);
  }

  void joinRoom(String roomId) {
    _roomId = roomId;
    LongLinkDebugExampleService.updateConnection(roomId: _roomId);
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      LongLinkDebugExampleService.updateHeartbeat(
        status: LongConnectionHeartbeatStatus.healthy,
        lastHeartbeatAt: DateTime.now(),
        roomId: _roomId,
      );
    });
  }

  void mockIncomingMessage() {
    final payload = <String, Object?>{
      'event': 'room.message',
      'msgId': DateTime.now().millisecondsSinceEpoch.toString(),
      'payload': <String, Object?>{
        'roomId': _roomId,
        'text': 'hello from mock long link',
      },
    };
    LongLinkDebugExampleService.recordIncomingMessage(
      channel: _roomId.isEmpty ? 'global' : 'room:$_roomId',
      bytes: payload.toString().length,
      payload: payload,
    );
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _retryTimer?.cancel();
  }
}
