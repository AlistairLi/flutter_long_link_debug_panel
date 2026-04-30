# flutter_long_link_debug_panel

`flutter_long_link_debug_panel` 是一个可复用的 Flutter 长连接调试面板，适合社交 App、语聊房 App、IM App 在开发、Profile 和测试环境中查看 WebSocket、TCP、MQTT 或自研长连通道的运行状态。

库内不依赖任何业务代码。业务项目只需要把自己的长连状态、心跳、指令日志和错误日志写入 `LongConnectionDebugController`。

## 目录结构

```text
lib/
  flutter_long_link_debug_panel.dart
  src/
    controllers/
      long_connection_debug_controller.dart
    models/
      long_connection_status.dart
      long_connection_command_log.dart
      long_connection_error_log.dart
      long_connection_debug_state.dart
    widgets/
      long_connection_debug_panel.dart
      long_connection_debug_button.dart
      long_connection_debug_overlay.dart
```

## 暴露能力

- `LongConnectionDebugPanel`：完整调试面板页面。
- `LongConnectionDebugButton`：打开调试面板的悬浮按钮。
- `LongConnectionDebugOverlay`：把调试入口叠加到业务页面上。
- `LongConnectionDebugController`：业务侧写入状态和日志的数据入口。
- `LongConnectionDebugState`：面板完整状态快照。
- `LongConnectionStatus`：长连接状态。
- `LongConnectionHeartbeatStatus`：心跳状态。
- `LongConnectionCommandLog`：指令日志。
- `LongConnectionErrorLog`：错误日志。

## 环境开关

所有入口 Widget 的 `enabled` 默认值为 `null`：

- Debug：默认展示。
- Profile：默认展示。
- Widget Test：默认展示。
- Release：默认不展示。

业务侧也可以显式传入 `enabled: true` 或 `enabled: false` 覆盖默认行为。

## 基础接入

```dart
import 'package:flutter_long_link_debug_panel/flutter_long_link_debug_panel.dart';

final longLinkDebugController = LongConnectionDebugController();
```

在业务页面外层加调试入口：

```dart
LongConnectionDebugOverlay(
  controller: longLinkDebugController,
  child: const HomePage(),
)
```

也可以直接打开完整页面：

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => LongConnectionDebugPanel(
      controller: longLinkDebugController,
    ),
  ),
);
```

## 写入连接状态

```dart
longLinkDebugController.updateConnection(
  status: LongConnectionStatus.connected,
  currentUrl: 'wss://im.example.com/ws?uid=10001',
  reconnectCount: 0,
  extra: const {
    'userId': '10001',
    'roomId': '8888',
  },
);
```

## 写入心跳状态

```dart
longLinkDebugController.updateHeartbeat(
  status: LongConnectionHeartbeatStatus.healthy,
  lastHeartbeatAt: DateTime.now(),
);
```

## 写入指令日志

```dart
longLinkDebugController.addCommand(
  const LongConnectionCommandLog(
    type: 'room.message',
    rawData: {
      'cmd': 'room.message',
      'payload': {'text': 'hello'},
    },
    parsedResult: {
      'text': 'hello',
    },
  ),
);
```

`rawData` 和 `parsedResult` 支持 `String`、`Map`、`List` 或业务自定义对象。面板会优先按 JSON 格式展示，无法编码时使用 `toString()`。

## 写入错误日志

```dart
try {
  // decode command
} catch (error, stackTrace) {
  longLinkDebugController.addError(
    LongConnectionErrorLog(
      message: '指令解析失败',
      detail: error,
      stackTrace: stackTrace,
      level: LongConnectionErrorLevel.error,
    ),
  );
}
```

## 推荐封装方式

业务项目可以在自己的长连模块里做一层 adapter，避免 UI 层直接感知长连实现：

```dart
class ImLongLinkDebugAdapter {
  ImLongLinkDebugAdapter(this.controller);

  final LongConnectionDebugController controller;

  void onConnected(String url) {
    controller.updateConnection(
      status: LongConnectionStatus.connected,
      currentUrl: url,
    );
  }

  void onReconnect(int count) {
    controller.updateConnection(
      status: LongConnectionStatus.reconnecting,
      reconnectCount: count,
    );
  }

  void onPong() {
    controller.updateHeartbeat(
      status: LongConnectionHeartbeatStatus.healthy,
      lastHeartbeatAt: DateTime.now(),
    );
  }

  void onCommand(Map<String, Object?> packet) {
    controller.addCommand(
      LongConnectionCommandLog(
        type: '${packet['cmd']}',
        rawData: packet,
        parsedResult: packet['payload'],
      ),
    );
  }
}
```

## 清理

`LongConnectionDebugController` 继承自 `ValueNotifier`，如果由页面或服务对象创建，需要在生命周期结束时释放：

```dart
@override
void dispose() {
  longLinkDebugController.dispose();
  super.dispose();
}
```
