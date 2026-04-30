import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import 'debug_panel_environment.dart';
import 'long_connection_debug_panel.dart';

/// 打开长连接调试面板的入口按钮。
class LongConnectionDebugButton extends StatelessWidget {
  const LongConnectionDebugButton({
    super.key,
    required this.controller,
    this.enabled,
    this.title = '长连接调试面板',
    this.tooltip = '长连接调试',
    this.icon = Icons.settings_input_antenna,
    this.onPressed,
  });

  /// 面板数据源。
  final LongConnectionDebugController controller;

  /// 不传时 release 关闭，debug/profile/test 开启。
  final bool? enabled;

  /// 面板标题。
  final String title;

  /// 按钮提示文案。
  final String tooltip;

  /// 按钮图标。
  final IconData icon;

  /// 业务侧需要自定义打开方式时传入。
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!longConnectionDebugPanelEnabled(enabled)) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.small(
      heroTag: null,
      tooltip: tooltip,
      onPressed: onPressed ?? () => _openPanel(context),
      child: Icon(icon),
    );
  }

  void _openPanel(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            LongConnectionDebugPanel(controller: controller, title: title),
      ),
    );
  }
}
