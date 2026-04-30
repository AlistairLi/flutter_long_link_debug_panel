import 'package:flutter/foundation.dart';

/// release 默认关闭；debug、profile 和测试环境默认开启。
bool longConnectionDebugPanelEnabled(bool? enabled) {
  return enabled ?? !kReleaseMode;
}
