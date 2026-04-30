import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import 'debug_panel_environment.dart';
import 'long_connection_debug_button.dart';

/// 将调试入口悬浮到业务页面之上。
class LongConnectionDebugOverlay extends StatelessWidget {
  const LongConnectionDebugOverlay({
    super.key,
    required this.child,
    required this.controller,
    this.enabled,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(16),
    this.title = '长连接调试面板',
    this.buttonBuilder,
  });

  /// 业务页面。
  final Widget child;

  /// 面板数据源。
  final LongConnectionDebugController controller;

  /// 不传时 release 关闭，debug/profile/test 开启。
  final bool? enabled;

  /// 悬浮按钮位置。
  final AlignmentGeometry alignment;

  /// 悬浮按钮边距。
  final EdgeInsetsGeometry padding;

  /// 面板标题。
  final String title;

  /// 自定义入口按钮，适合接入项目已有设计系统。
  final Widget Function(
    BuildContext context,
    LongConnectionDebugController controller,
  )?
  buttonBuilder;

  @override
  Widget build(BuildContext context) {
    if (!longConnectionDebugPanelEnabled(enabled)) {
      return child;
    }

    return Stack(
      children: <Widget>[
        child,
        SafeArea(
          child: Padding(
            padding: padding,
            child: Align(
              alignment: alignment,
              child:
                  buttonBuilder?.call(context, controller) ??
                  LongConnectionDebugButton(
                    controller: controller,
                    title: title,
                    enabled: enabled,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
