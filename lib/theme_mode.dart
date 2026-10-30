import 'package:flutter/material.dart';
// 只需要设计 token 时，可以用这个窄 barrel 代替完整的 widgets_easier.dart。
import 'package:widgets_easier/theme.dart';

// 管理主题模式
ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// 品牌主色，用来演示 WeColorScheme.copyWith 派生自定义调色板。
final ValueNotifier<Color> brandColor = ValueNotifier<Color>(
  const WeColorScheme.light().primary,
);
