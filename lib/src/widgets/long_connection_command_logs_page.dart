import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';

/// 长连接指令日志列表页面。
class LongConnectionCommandLogsPage extends StatelessWidget {
  const LongConnectionCommandLogsPage({
    super.key,
    this.controller,
    this.commandLogs = const <LongConnectionCommandLog>[],
  });

  final LongConnectionDebugController? controller;
  final List<LongConnectionCommandLog> commandLogs;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller != null) {
      return ValueListenableBuilder<LongConnectionDebugState>(
        valueListenable: controller,
        builder: (context, state, _) {
          return _CommandLogsScaffold(commandLogs: state.commandLogs);
        },
      );
    }

    return _CommandLogsScaffold(commandLogs: commandLogs);
  }
}

class _CommandLogsScaffold extends StatelessWidget {
  const _CommandLogsScaffold({required this.commandLogs});

  final List<LongConnectionCommandLog> commandLogs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('最近收到的指令')),
      body: SafeArea(
        child: commandLogs.isEmpty
            ? Center(
                child: Text(
                  '暂无指令日志',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  return _CommandTile(log: commandLogs[index]);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: commandLogs.length,
              ),
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({required this.log});

  final LongConnectionCommandLog log;

  @override
  Widget build(BuildContext context) {
    final direction = log.isIncoming ? '收到' : '发出';
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      collapsedBackgroundColor:
          Theme.of(context).colorScheme.surfaceContainerHighest,
      title: Text(
        '$direction\n${log.type}',
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_formatTime(log.timestamp)),
      trailing: IconButton(
        tooltip: '复制指令原始数据',
        onPressed: () => _copyRawData(context, log.rawData),
        icon: const Icon(Icons.copy),
      ),
      children: <Widget>[
        if (log.id != null) _InfoRow(label: '指令 ID', value: log.id!),
        _InfoRow(label: '指令类型', value: log.type),
        _PayloadBlock(label: '指令原始数据', value: log.rawData),
        // _PayloadBlock(label: '指令解析结果', value: log.parsedResult),
      ],
    );
  }

  void _copyRawData(BuildContext context, Object? rawData) {
    Clipboard.setData(ClipboardData(text: _formatPayload(rawData)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制指令原始数据')),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
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
