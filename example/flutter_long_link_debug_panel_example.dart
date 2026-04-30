import 'package:flutter_long_link_debug_panel/flutter_long_link_debug_panel.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final LongConnectionDebugController _debugController =
      LongConnectionDebugController();

  @override
  void initState() {
    super.initState();
    _mockLongConnectionData();
  }

  @override
  void dispose() {
    _debugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LongConnectionDebugOverlay(
        controller: _debugController,
        child: const Scaffold(body: Center(child: Text('业务页面'))),
      ),
    );
  }

  void _mockLongConnectionData() {
    _debugController.updateConnection(
      status: LongConnectionStatus.connected,
      currentUrl: 'wss://im.example.com/ws?uid=10001',
      reconnectCount: 0,
      extra: const <String, Object?>{'userId': '10001', 'roomId': '8888'},
    );
    _debugController.updateHeartbeat(
      status: LongConnectionHeartbeatStatus.healthy,
      lastHeartbeatAt: DateTime.now(),
    );
    _debugController.addCommand(
      const LongConnectionCommandLog(
        type: 'room.message',
        rawData: {
          'cmd': 'room.message',
          'payload': {'text': 'hello'},
        },
        parsedResult: {'text': 'hello'},
      ),
    );
    _debugController.addError(
      const LongConnectionErrorLog(
        message: '示例错误日志',
        detail: {'code': 1001, 'reason': 'decode failed'},
      ),
    );
  }
}
