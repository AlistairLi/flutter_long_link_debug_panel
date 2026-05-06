import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import 'debug_panel_environment.dart';
import 'long_connection_command_logs_page.dart';

/// 可复用的长连接调试面板页面。
class LongConnectionDebugPanel extends StatelessWidget {
  const LongConnectionDebugPanel({
    super.key,
    this.controller,
    this.state,
    this.enabled,
    this.title = '长连接调试面板',
    this.showAppBar = true,
    this.showBackToFloatingButton = false,
    this.onBackToFloating,
    this.onConnect,
    this.onDisconnect,
    this.commandLogsNavigationEnabled = true,
    this.padding = const EdgeInsets.all(12),
  }) : assert(controller != null || state != null, 'controller 和 state 至少传入一个');

  /// 推荐传入 controller，面板会自动刷新。
  final LongConnectionDebugController? controller;

  /// 不需要自动刷新时可以直接传入状态快照。
  final LongConnectionDebugState? state;

  /// 不传时 release 关闭，debug/profile/test 开启。
  final bool? enabled;

  /// 页面标题。
  final String title;

  /// 嵌入已有页面时可关闭 AppBar。
  final bool showAppBar;

  /// 是否显示切回悬浮核心数据 UI 的按钮。
  final bool showBackToFloatingButton;

  /// 点击切回悬浮核心数据 UI。
  final VoidCallback? onBackToFloating;

  /// 点击连接开关时发起连接。
  final VoidCallback? onConnect;

  /// 点击连接开关时断开连接。
  final VoidCallback? onDisconnect;

  /// 是否允许从面板跳转到指令详情页。
  final bool commandLogsNavigationEnabled;

  /// 内容边距。
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!longConnectionDebugPanelEnabled(enabled)) {
      return const SizedBox.shrink();
    }

    final controller = this.controller;
    if (controller != null) {
      return ValueListenableBuilder<LongConnectionDebugState>(
        valueListenable: controller,
        builder: (context, state, _) => _PanelScaffold(
          title: title,
          controller: controller,
          state: state,
          showAppBar: showAppBar,
          showBackToFloatingButton: showBackToFloatingButton,
          onBackToFloating: onBackToFloating,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
          commandLogsNavigationEnabled: commandLogsNavigationEnabled,
          padding: padding,
        ),
      );
    }

    return _PanelScaffold(
      title: title,
      controller: null,
      state: state!,
      showAppBar: showAppBar,
      showBackToFloatingButton: showBackToFloatingButton,
      onBackToFloating: onBackToFloating,
      onConnect: onConnect,
      onDisconnect: onDisconnect,
      commandLogsNavigationEnabled: commandLogsNavigationEnabled,
      padding: padding,
    );
  }
}

class _PanelScaffold extends StatelessWidget {
  const _PanelScaffold({
    required this.title,
    required this.controller,
    required this.state,
    required this.showAppBar,
    required this.showBackToFloatingButton,
    required this.onBackToFloating,
    required this.onConnect,
    required this.onDisconnect,
    required this.commandLogsNavigationEnabled,
    required this.padding,
  });

  final String title;
  final LongConnectionDebugController? controller;
  final LongConnectionDebugState state;
  final bool showAppBar;
  final bool showBackToFloatingButton;
  final VoidCallback? onBackToFloating;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final bool commandLogsNavigationEnabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: padding,
      children: <Widget>[
        if (showBackToFloatingButton) ...<Widget>[
          _PanelHeader(title: title, onBackToFloating: onBackToFloating),
          const SizedBox(height: 12),
        ],
        _SummarySection(
          state: state,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
        ),
        const SizedBox(height: 12),
        _HeartbeatSection(state: state),
        const SizedBox(height: 12),
        _CommandSection(
          controller: controller,
          commandLogs: state.commandLogs,
          navigationEnabled: commandLogsNavigationEnabled,
        ),
        const SizedBox(height: 12),
        _ErrorSection(errorLogs: state.errorLogs),
        if (state.extra.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _ExtraSection(extra: state.extra),
        ],
      ],
    );

    if (!showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(title),
        actions: <Widget>[
          if (showBackToFloatingButton)
            IconButton(
              tooltip: '回到悬浮核心数据',
              onPressed: onBackToFloating,
              icon: const Icon(Icons.close_fullscreen),
            ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.onBackToFloating,
  });

  final String title;
  final VoidCallback? onBackToFloating;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '悬浮面板',
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            IconButton(
              tooltip: '回到悬浮核心数据',
              onPressed: onBackToFloating,
              icon: const Icon(Icons.close_fullscreen),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
  });

  final LongConnectionDebugState state;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '连接概览',
      children: <Widget>[
        _ConnectionSwitchRow(
          status: state.connectionStatus,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
        ),
        _InfoRow(
          label: '连接状态',
          value: state.connectionStatus.label,
          valueColor: _statusColor(context, state.connectionStatus),
        ),
        _InfoRow(
          label: '当前连接地址',
          value: state.currentUrl.isEmpty ? '-' : state.currentUrl,
        ),
        _InfoRow(label: '重连次数', value: '${state.reconnectCount}'),
        if (_shouldShowNextReconnect(state))
          _NextReconnectRow(nextReconnectAt: state.nextReconnectAt),
        _InfoRow(label: '最近更新时间', value: _formatTime(state.updatedAt)),
      ],
    );
  }

  bool _shouldShowNextReconnect(LongConnectionDebugState state) {
    return state.connectionStatus == LongConnectionStatus.failed &&
        state.nextReconnectAt != null;
  }
}

class _NextReconnectRow extends StatefulWidget {
  const _NextReconnectRow({required this.nextReconnectAt});

  final DateTime? nextReconnectAt;

  @override
  State<_NextReconnectRow> createState() => _NextReconnectRowState();
}

class _NextReconnectRowState extends State<_NextReconnectRow> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      label: '下次重连',
      value: _formatRemainingTime(widget.nextReconnectAt),
    );
  }
}

class _ConnectionSwitchRow extends StatelessWidget {
  const _ConnectionSwitchRow({
    required this.status,
    required this.onConnect,
    required this.onDisconnect,
  });

  final LongConnectionStatus status;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isBusy = status == LongConnectionStatus.connecting ||
        status == LongConnectionStatus.reconnecting;
    final isOn = status == LongConnectionStatus.connected || isBusy;
    final canToggle =
        !isBusy && (isOn ? onDisconnect != null : onConnect != null);
    final onChanged = !canToggle
        ? null
        : (bool value) {
            if (value) {
              onConnect!();
            } else {
              onDisconnect!();
            }
          };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              '连接开关',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _switchLabel(status),
              style: TextStyle(
                color: _statusColor(context, status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(value: isOn, onChanged: onChanged),
        ],
      ),
    );
  }

  String _switchLabel(LongConnectionStatus status) {
    switch (status) {
      case LongConnectionStatus.connected:
        return '开';
      case LongConnectionStatus.connecting:
        return '连接中';
      case LongConnectionStatus.reconnecting:
        return '重连中';
      case LongConnectionStatus.failed:
      case LongConnectionStatus.disconnected:
        return '关';
    }
  }
}

class _HeartbeatSection extends StatelessWidget {
  const _HeartbeatSection({required this.state});

  final LongConnectionDebugState state;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '房间心跳',
      children: <Widget>[
        _InfoRow(
          label: '当前房间',
          value: state.currentRoomId.isEmpty ? '-' : state.currentRoomId,
        ),
        _InfoRow(
          label: '心跳状态',
          value: state.heartbeatStatus.label,
          valueColor: _heartbeatColor(context, state.heartbeatStatus),
        ),
        _InfoRow(label: '最近心跳时间', value: _formatTime(state.lastHeartbeatAt)),
      ],
    );
  }
}

class _CommandSection extends StatelessWidget {
  const _CommandSection({
    required this.controller,
    required this.commandLogs,
    required this.navigationEnabled,
  });

  final LongConnectionDebugController? controller;
  final List<LongConnectionCommandLog> commandLogs;
  final bool navigationEnabled;

  @override
  Widget build(BuildContext context) {
    final canNavigate = navigationEnabled && Navigator.maybeOf(context) != null;
    return _SectionCard(
      title: '最近收到的指令',
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('共 ${commandLogs.length} 条'),
          subtitle: Text(_subtitle(canNavigate)),
          trailing: canNavigate ? const Icon(Icons.chevron_right) : null,
          onTap: canNavigate
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LongConnectionCommandLogsPage(
                        controller: controller,
                        commandLogs: commandLogs,
                      ),
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }

  String _subtitle(bool canNavigate) {
    if (commandLogs.isEmpty) {
      return '暂无指令日志';
    }
    return canNavigate ? '点击查看指令详情' : '悬浮详情中不可打开指令详情页';
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.errorLogs});

  final List<LongConnectionErrorLog> errorLogs;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '错误日志',
      emptyText: '暂无错误日志',
      children:
          errorLogs.map((log) => _ErrorTile(log: log)).toList(growable: false),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.log});

  final LongConnectionErrorLog log;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        log.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: _errorLevelColor(context, log.level)),
      ),
      subtitle: Text('${log.level.name} · ${_formatTime(log.timestamp)}'),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: <Widget>[
        _PayloadBlock(label: '错误详情', value: log.detail),
        _PayloadBlock(label: '堆栈信息', value: log.stackTrace),
      ],
    );
  }
}

class _ExtraSection extends StatelessWidget {
  const _ExtraSection({required this.extra});

  final Map<String, Object?> extra;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '扩展信息',
      children: extra.entries
          .map((entry) => _InfoRow(label: entry.key, value: '${entry.value}'))
          .toList(growable: false),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.emptyText,
  });

  final String title;
  final List<Widget> children;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (children.isEmpty)
              Text(
                emptyText ?? '暂无数据',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 102,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor == null ? null : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayloadBlock extends StatelessWidget {
  const _PayloadBlock({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: SelectableText(
                  _formatPayload(value),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPayload(Object? value) {
  if (value == null) {
    return '-';
  }
  if (value is String) {
    return value;
  }
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}

String _formatTime(DateTime? time) {
  if (time == null) {
    return '-';
  }
  final local = time.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final date = [
    local.year.toString().padLeft(4, '0'),
    twoDigits(local.month),
    twoDigits(local.day),
  ].join('-');
  final clock = [
    twoDigits(local.hour),
    twoDigits(local.minute),
    twoDigits(local.second),
  ].join(':');
  return '$date $clock';
}

String _formatRemainingTime(DateTime? time) {
  if (time == null) {
    return '-';
  }
  final remaining = time.difference(DateTime.now());
  if (remaining.isNegative) {
    return '即将重连';
  }
  if (remaining.inMinutes >= 1) {
    return '${remaining.inMinutes} 分 ${remaining.inSeconds.remainder(60)} 秒后';
  }
  return '${remaining.inSeconds} 秒后';
}

Color _statusColor(BuildContext context, LongConnectionStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case LongConnectionStatus.connected:
      return Colors.green;
    case LongConnectionStatus.connecting:
    case LongConnectionStatus.reconnecting:
      return colorScheme.primary;
    case LongConnectionStatus.failed:
      return colorScheme.error;
    case LongConnectionStatus.disconnected:
      return colorScheme.onSurfaceVariant;
  }
}

Color _heartbeatColor(
  BuildContext context,
  LongConnectionHeartbeatStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case LongConnectionHeartbeatStatus.healthy:
      return Colors.green;
    case LongConnectionHeartbeatStatus.timeout:
    case LongConnectionHeartbeatStatus.failed:
      return colorScheme.error;
    case LongConnectionHeartbeatStatus.idle:
      return colorScheme.onSurfaceVariant;
  }
}

Color _errorLevelColor(BuildContext context, LongConnectionErrorLevel level) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (level) {
    case LongConnectionErrorLevel.info:
      return colorScheme.primary;
    case LongConnectionErrorLevel.warning:
      return Colors.orange;
    case LongConnectionErrorLevel.error:
      return colorScheme.error;
  }
}
