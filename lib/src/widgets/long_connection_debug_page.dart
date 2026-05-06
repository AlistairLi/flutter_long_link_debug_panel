import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import 'long_connection_debug_overlay.dart';
import 'long_connection_debug_panel.dart';

/// 带悬浮开关的长连接调试页面。
class LongConnectionDebugPage extends StatelessWidget {
  const LongConnectionDebugPage({
    super.key,
    required this.controller,
    this.enabled,
    this.title = '长连接调试面板',
    this.onConnect,
    this.onDisconnect,
  });

  final LongConnectionDebugController controller;
  final bool? enabled;
  final String title;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: LongConnectionDebugOverlayController.visibility,
            builder: (context, isVisible, _) {
              return IconButton(
                tooltip: isVisible ? '隐藏悬浮窗' : '显示悬浮窗',
                onPressed: () {
                  if (isVisible) {
                    LongConnectionDebugOverlayController.hide();
                  } else {
                    LongConnectionDebugOverlayController.show(
                      context,
                      controller: controller,
                      enabled: enabled,
                      title: title,
                      onConnect: onConnect,
                      onDisconnect: onDisconnect,
                    );
                  }
                },
                icon: Icon(
                  isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LongConnectionDebugPanel(
          controller: controller,
          enabled: enabled,
          title: title,
          showAppBar: false,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
        ),
      ),
    );
  }
}
