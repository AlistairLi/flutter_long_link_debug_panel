import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import 'debug_panel_environment.dart';
import 'long_connection_debug_button.dart';
import 'long_connection_debug_panel.dart';

enum LongConnectionDebugOverlayMode { compact, expanded }

class LongConnectionDebugOverlayController {
  LongConnectionDebugOverlayController._();

  static OverlayEntry? _entry;
  static LongConnectionDebugController? _controller;
  static bool? _enabled;
  static String _title = '长连接调试面板';
  static VoidCallback? _onConnect;
  static VoidCallback? _onDisconnect;

  static final ValueNotifier<bool> visibility = ValueNotifier<bool>(false);
  static final ValueNotifier<LongConnectionDebugOverlayMode> mode =
      ValueNotifier<LongConnectionDebugOverlayMode>(
    LongConnectionDebugOverlayMode.compact,
  );

  static bool get isShowing => _entry != null;

  static void show(
    BuildContext context, {
    required LongConnectionDebugController controller,
    bool? enabled,
    String title = '长连接调试面板',
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
  }) {
    showCompact(
      context,
      controller,
      enabled,
      title,
      onConnect,
      onDisconnect,
    );
  }

  static void showCompact([
    BuildContext? context,
    LongConnectionDebugController? controller,
    bool? enabled,
    String title = '长连接调试面板',
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
  ]) {
    _ensureEntry(
      context,
      controller: controller,
      enabled: enabled,
      title: title,
      onConnect: onConnect,
      onDisconnect: onDisconnect,
    );
    if (_entry == null) {
      return;
    }
    mode.value = LongConnectionDebugOverlayMode.compact;
    visibility.value = true;
  }

  static void showExpanded(
    BuildContext context, {
    required LongConnectionDebugController controller,
    bool? enabled,
    String title = '长连接调试面板',
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
  }) {
    _ensureEntry(
      context,
      controller: controller,
      enabled: enabled,
      title: title,
      onConnect: onConnect,
      onDisconnect: onDisconnect,
    );
    if (_entry == null) {
      return;
    }
    mode.value = LongConnectionDebugOverlayMode.expanded;
    visibility.value = true;
  }

  static void _ensureEntry(
    BuildContext? context, {
    LongConnectionDebugController? controller,
    bool? enabled,
    String title = '长连接调试面板',
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
  }) {
    if (controller != null) {
      _controller = controller;
    }
    _enabled = enabled;
    _title = title;
    _onConnect = onConnect ?? _onConnect;
    _onDisconnect = onDisconnect ?? _onDisconnect;

    if (!longConnectionDebugPanelEnabled(_enabled)) {
      return;
    }
    if (_entry != null || context == null || _controller == null) {
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _entry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          child: ValueListenableBuilder<LongConnectionDebugOverlayMode>(
            valueListenable: mode,
            builder: (context, currentMode, _) {
              final controller = _controller;
              if (controller == null) {
                return const SizedBox.shrink();
              }

              if (currentMode == LongConnectionDebugOverlayMode.compact) {
                return Material(
                  type: MaterialType.transparency,
                  child: _CompactLongConnectionDebugWidget(
                    controller: controller,
                    onTap: () => showExpanded(
                      context,
                      controller: controller,
                      enabled: _enabled,
                      title: _title,
                      onConnect: _onConnect,
                      onDisconnect: _onDisconnect,
                    ),
                  ),
                );
              }

              return Material(
                color: Colors.black.withValues(alpha: 0.35),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showCompact(
                    context,
                    controller,
                    _enabled,
                    _title,
                    _onConnect,
                    _onDisconnect,
                  ),
                  child: SafeArea(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: LongConnectionDebugPanel(
                              controller: controller,
                              enabled: _enabled,
                              title: _title,
                              showAppBar: false,
                              showBackToFloatingButton: true,
                              onBackToFloating: () => showCompact(
                                context,
                                controller,
                                _enabled,
                                _title,
                                _onConnect,
                                _onDisconnect,
                              ),
                              onConnect: _onConnect,
                              onDisconnect: _onDisconnect,
                              commandLogsNavigationEnabled: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    overlay.insert(_entry!);
    visibility.value = true;
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
    _onConnect = null;
    _onDisconnect = null;
    mode.value = LongConnectionDebugOverlayMode.compact;
    visibility.value = false;
  }
}

class _CompactLongConnectionDebugWidget extends StatelessWidget {
  const _CompactLongConnectionDebugWidget({
    required this.controller,
    required this.onTap,
  });

  final LongConnectionDebugController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<LongConnectionDebugState>(
          valueListenable: controller,
          builder: (context, state, _) {
            final errorCount = state.errorLogs.length;
            return GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.only(top: 46),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.1,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _statusColor(state.connectionStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(state.connectionStatus.label),
                      const SizedBox(width: 8),
                      Text('Msg:${state.commandLogs.length}'),
                      if (state.reconnectCount > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Text('R:${state.reconnectCount}'),
                      ],
                      if (errorCount > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Text('E:$errorCount'),
                      ],
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.open_in_full,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(LongConnectionStatus status) {
    switch (status) {
      case LongConnectionStatus.connected:
        return const Color(0xFF53D769);
      case LongConnectionStatus.connecting:
      case LongConnectionStatus.reconnecting:
        return const Color(0xFFFFC107);
      case LongConnectionStatus.failed:
        return const Color(0xFFFF5252);
      case LongConnectionStatus.disconnected:
        return Colors.grey;
    }
  }
}

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
  )? buttonBuilder;

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
              child: buttonBuilder?.call(context, controller) ??
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
