import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// 时间范围快捷选择 + 起止日期 + 刷新，放在每个数据页的最上面。
///
/// 快捷范围用 [WeSegmented]，起止日期是可以直接键入的 [WeDatePicker.range]，
/// 「固定」是 [CheckTag]，刷新与导出是 [WeButtonGroup]，全部来自组件库。
class RangeFilterBar extends StatefulWidget {
  const RangeFilterBar({
    super.key,
    required this.onRefresh,
    this.onExport,
    this.note = '数据每 5 分钟聚合一次，导出会按当前筛选条件生成 CSV。',
  });

  final VoidCallback onRefresh;
  final VoidCallback? onExport;
  final String note;

  @override
  State<RangeFilterBar> createState() => _RangeFilterBarState();
}

class _RangeFilterBarState extends State<RangeFilterBar> {
  /// 演示数据停在这一天，所有相对范围都从它算起。
  static final DateTime _today = DateTime(2026, 9, 20);

  static const List<WeSegmentedOption<int?>> _ranges = [
    WeSegmentedOption(0, '今日'),
    WeSegmentedOption(1, '昨日'),
    WeSegmentedOption(2, '近 7 天'),
    WeSegmentedOption(3, '近 30 天'),
    WeSegmentedOption(4, '本月'),
    WeSegmentedOption(5, '本季度'),
  ];

  static DateTimeRange _preset(int i) {
    final DateTime t = _today;
    DateTime back(int days) => DateTime(t.year, t.month, t.day - days);
    return switch (i) {
      0 => DateTimeRange(start: t, end: t),
      1 => DateTimeRange(start: back(1), end: back(1)),
      2 => DateTimeRange(start: back(6), end: t),
      3 => DateTimeRange(start: back(29), end: t),
      4 => DateTimeRange(start: DateTime(t.year, t.month), end: t),
      _ => DateTimeRange(
        start: DateTime(t.year, (t.month - 1) ~/ 3 * 3 + 1),
        end: t,
      ),
    };
  }

  static final List<WeDateShortcut<DateTimeRange>> _shortcuts = [
    for (final o in _ranges) WeDateShortcut(o.label, () => _preset(o.value!)),
    WeDateShortcut(
      '上个月',
      () => DateTimeRange(
        start: DateTime(_today.year, _today.month - 1),
        end: DateTime(_today.year, _today.month, 0),
      ),
    ),
  ];

  /// 手动挑的日期不对应任何快捷项时为 `null`。
  int? _selected = 2;
  bool _pinned = true;
  DateTimeRange _range = _preset(2);

  void _setRange(DateTimeRange r) {
    int? match;
    for (final o in _ranges) {
      final p = _preset(o.value!);
      if (DateUtils.isSameDay(p.start, r.start) &&
          DateUtils.isSameDay(p.end, r.end)) {
        match = o.value;
        break;
      }
    }
    setState(() {
      _range = r;
      _selected = match;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return WeCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WeSegmented<int?>(
                size: SizeEnum.small,
                options: _ranges,
                value: _selected,
                onChanged: (v) {
                  if (v != null) _setRange(_preset(v));
                },
              ),
              const SizedBox(height: 18, child: WeDivider.vertical()),
              WeDatePicker.range(
                range: _range,
                size: SizeEnum.small,
                width: 260,
                clearable: false,
                firstDate: DateTime(2024),
                lastDate: _today,
                shortcuts: _shortcuts,
                onChanged: (r) {
                  if (r != null) _setRange(r);
                },
              ),
              CheckTag(
                '固定',
                size: SizeEnum.small,
                showCheckIcon: true,
                checked: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
              ),
              WeButtonGroup(
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                children: [
                  WeButton(
                    text: '刷新',
                    icon: Icons.refresh_rounded,
                    onPressed: widget.onRefresh,
                  ),
                  WeButton(
                    text: '导出',
                    icon: Icons.download_outlined,
                    onPressed:
                        widget.onExport ??
                        () => WeMessage.success(context, '已按当前筛选生成导出任务'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: colors.placeholderText,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: WeText(
                  '${_selected == null ? '自定义' : _ranges[_selected!].label}：'
                  '${weFormatDate(_range.start)} ~ ${weFormatDate(_range.end)}。${widget.note}',
                  role: WeTextRole.placeholder,
                  size: SizeEnum.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 顶部通知条：[WeAlert] 的电商后台封装，标题加粗、正文跟在后面。
class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onClose,
    this.action,
    this.dark = false,
  });

  final SemanticEnum type;
  final String title;
  final String message;
  final VoidCallback? onClose;
  final Widget? action;

  /// 实底样式，用在需要强提醒的地方。
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return WeAlert(
      type: type,
      title: title,
      description: message,
      effect: dark ? WeAlertEffect.dark : WeAlertEffect.light,
      closable: onClose != null,
      onClose: onClose,
      action: action,
    );
  }
}

/// 空状态：[WeEmpty] 加一行副说明。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title = '暂无数据',
    this.description = '换个时间范围或筛选条件再试试',
    this.action,
    this.height = 220,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String description;
  final Widget? action;
  final double height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: WeEmpty(
          icon: icon,
          imageSize: 84,
          description: title,
          padding: EdgeInsets.zero,
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WeText(
                description,
                role: WeTextRole.placeholder,
                size: SizeEnum.small,
              ),
              if (action != null) ...[const SizedBox(height: 14), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// 搜索框：带清除按钮的 [WeInput]。
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    this.width = 240,
    this.onChanged,
    this.onSubmitted,
    this.size = SizeEnum.defaultSize,
  });

  final String hint;
  final double width;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final SizeEnum size;

  @override
  Widget build(BuildContext context) {
    return WeInput(
      width: width,
      size: size,
      hint: hint,
      prefixIcon: Icons.search_rounded,
      clearable: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
