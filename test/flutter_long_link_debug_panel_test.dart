import 'package:flutter/material.dart';
import 'package:flutter_long_link_debug_panel/flutter_long_link_debug_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller updates connection state and limits command logs', () {
    final controller = LongConnectionDebugController(maxCommandLogCount: 2);

    controller.updateConnection(
      status: LongConnectionStatus.connected,
      currentUrl: 'wss://example.com/socket',
    );
    controller.addCommand(
      const LongConnectionCommandLog(type: 'first', rawData: {'id': 1}),
    );
    controller.addCommand(
      const LongConnectionCommandLog(type: 'second', rawData: {'id': 2}),
    );
    controller.addCommand(
      const LongConnectionCommandLog(type: 'third', rawData: {'id': 3}),
    );

    expect(controller.value.connectionStatus, LongConnectionStatus.connected);
    expect(controller.value.currentUrl, 'wss://example.com/socket');
    expect(controller.value.commandLogs, hasLength(2));
    expect(controller.value.commandLogs.first.type, 'third');
  });

  testWidgets('panel displays connection and command information', (
    tester,
  ) async {
    final controller = LongConnectionDebugController(
      initialState: LongConnectionDebugState(
        connectionStatus: LongConnectionStatus.connected,
        currentUrl: 'wss://example.com/socket',
        heartbeatStatus: LongConnectionHeartbeatStatus.healthy,
        lastHeartbeatAt: DateTime(2026, 4, 30, 10, 30),
        reconnectCount: 1,
        commandLogs: const <LongConnectionCommandLog>[
          LongConnectionCommandLog(
            type: 'room.message',
            rawData: {'cmd': 'room.message'},
            parsedResult: {'text': 'hello'},
          ),
        ],
        errorLogs: const <LongConnectionErrorLog>[
          LongConnectionErrorLog(message: 'decode failed'),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: LongConnectionDebugPanel(controller: controller)),
    );

    expect(find.text('长连接调试面板'), findsOneWidget);
    expect(find.text('已连接'), findsOneWidget);
    expect(find.text('wss://example.com/socket'), findsOneWidget);
    expect(find.textContaining('room.message'), findsOneWidget);
    expect(find.textContaining('decode failed'), findsOneWidget);
  });
}
