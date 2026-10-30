import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_data.dart';
import '../widgets/charts.dart';
import '../widgets/kpi_card.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 经营概览：成交、履约、渠道、品类与待办一屏看完。
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _alertVisible = true;
  bool _rankEmpty = false;
  bool _rankLoading = false;
  String _agg = 'day';
  final Set<int> _done = {};

  static const List<String> _dayLabels = [
    '09-07',
    '09-08',
    '09-09',
    '09-10',
    '09-11',
    '09-12',
    '09-13',
    '09-14',
    '09-15',
    '09-16',
    '09-17',
    '09-18',
    '09-19',
    '09-20',
  ];

  Future<void> _dispatchTodos() async {
    final bool ok = await WeMessageBox.confirm(
      context,
      '将把 201 项待办分派给对应的运营与客服小组，确认继续？',
      title: '批量处理待办',
      confirmText: '确认分派',
      cancelText: '再想想',
      type: SemanticEnum.primary,
    );
    if (!ok || !mounted) return;

    WeNotification.show(
      context,
      title: '已分派',
      message: '201 项待办已进入各小组队列。',
      type: SemanticEnum.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final we = WeTheme.of(context);
    final colors = we.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: LayoutBuilder(
        builder: (context, box) {
          final double w = box.maxWidth;
          final int kpiColumns = w > 1180
              ? 4
              : w > 820
              ? 2
              : 1;
          final double kpiWidth = (w - (kpiColumns - 1) * 16) / kpiColumns;
          final bool twoUp = w > 1020;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WePageHeader(
                title: '经营概览',
                description: '2026 年 9 月 20 日 · 数据延迟约 5 分钟',
                tag: const Tag(
                  '实时',
                  type: SemanticEnum.success,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
                actions: [
                  WeButton(
                    text: '导出日报',
                    icon: Icons.download_rounded,
                    variant: WeButtonVariant.plain,
                    size: SizeEnum.small,
                    onPressed: () =>
                        WeMessage.success(context, '日报已生成，稍后发送到你的邮箱'),
                  ),
                  WeButton(
                    text: '自定义看板',
                    icon: Icons.tune_rounded,
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    onPressed: () => WeNotification.show(
                      context,
                      title: '看板配置',
                      message: '可以拖拽调整卡片顺序，配置只对当前账号生效。',
                      type: SemanticEnum.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              WeCarousel(
                height: 88,
                autoplay: true,
                interval: const Duration(seconds: 4),
                arrow: WeCarouselArrow.hover,
                children: [
                  for (final (title, desc, type) in [
                    ('今日大盘', '成交额已完成月目标的 64%', SemanticEnum.primary),
                    ('履约预警', '华南 3 个仓配延迟超过 12 小时', SemanticEnum.warning),
                    ('活动预告', '中秋礼盒将于周五 20:00 开售', SemanticEnum.success),
                  ])
                    WeAlert(
                      title: title,
                      description: desc,
                      type: type,
                      closable: false,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              RangeFilterBar(
                onRefresh: () => WeMessage.success(context, '已拉取最新数据'),
                onExport: () => WeMessage.info(context, '正在按当前筛选生成 CSV'),
              ),
              if (_alertVisible) ...[
                const SizedBox(height: 14),
                AlertBanner(
                  type: SemanticEnum.warning,
                  title: '库存预警',
                  message:
                      '12 个 SKU 低于安全库存，其中「无界降噪耳机 Air Pro」已售罄，预计影响今日 GMV 约 8.4 万元。',
                  action: WeButton(
                    text: '去补货',
                    size: SizeEnum.small,
                    type: SemanticEnum.warning,
                    onPressed: () => WeMessage.warning(context, '已跳转补货流程'),
                  ),
                  onClose: () => setState(() => _alertVisible = false),
                ),
              ],
              const SizedBox(height: 16),

              // ── 核心指标 ────────────────────────────────────────────
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: kpiWidth,
                    child: const KpiCard(
                      label: '今日成交额',
                      value: '74.9',
                      unit: '万元',
                      delta: 9.8,
                      compare: '较昨日 68.2 万',
                      icon: Icons.payments_outlined,
                      type: SemanticEnum.primary,
                      trend: kGmvTrend,
                      goal: 0.83,
                      goalLabel: '月目标 2400 万',
                    ),
                  ),
                  SizedBox(
                    width: kpiWidth,
                    child: const KpiCard(
                      label: '支付订单数',
                      value: '23,514',
                      unit: '单',
                      delta: 8.8,
                      compare: '较昨日 21,613 单',
                      icon: Icons.shopping_bag_outlined,
                      type: SemanticEnum.success,
                      trend: kOrderTrend,
                      goal: 0.76,
                      goalLabel: '月目标 92 万单',
                    ),
                  ),
                  SizedBox(
                    width: kpiWidth,
                    child: const KpiCard(
                      label: '客单价',
                      value: '318.5',
                      unit: '元',
                      delta: 1.2,
                      compare: '较昨日 314.7 元',
                      icon: Icons.sell_outlined,
                      type: SemanticEnum.warning,
                      trend: [
                        302,
                        298,
                        305,
                        311,
                        308,
                        316,
                        312,
                        309,
                        314,
                        317,
                        313,
                        319,
                        314.7,
                        318.5,
                      ],
                      goal: 0.64,
                      goalLabel: '目标 360 元',
                    ),
                  ),
                  SizedBox(
                    width: kpiWidth,
                    child: const KpiCard(
                      label: '退款率',
                      value: '2.14',
                      unit: '%',
                      delta: -0.4,
                      compare: '较昨日 2.54%',
                      icon: Icons.assignment_return_outlined,
                      type: SemanticEnum.danger,
                      trend: [
                        3.1,
                        3.0,
                        2.9,
                        3.2,
                        2.8,
                        2.7,
                        2.9,
                        2.6,
                        2.7,
                        2.5,
                        2.6,
                        2.4,
                        2.54,
                        2.14,
                      ],
                      goal: 0.91,
                      goalLabel: '红线 2.5% 以内',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 趋势 + 渠道 ─────────────────────────────────────────
              _TwoColumn(
                twoUp: twoUp,
                leftFlex: 5,
                rightFlex: 3,
                left: Panel(
                  title: '成交趋势',
                  subtitle: '柱：成交额（万元）　线：支付订单（千单）',
                  icon: Icons.show_chart_rounded,
                  trailing: WeSegmented<String>(
                    value: _agg,
                    size: SizeEnum.small,
                    onChanged: (v) => setState(() => _agg = v),
                    options: const [
                      WeSegmentedOption('day', '日'),
                      WeSegmentedOption('week', '周'),
                      WeSegmentedOption('month', '月'),
                    ],
                  ),
                  child: Column(
                    children: [
                      TrendChart(
                        bars: kGmvTrend,
                        line: kOrderTrend,
                        labels: _dayLabels,
                        barColor: colors.primary,
                        lineColor: colors.warning,
                      ),
                      const WeDivider(
                        margin: EdgeInsets.symmetric(vertical: 12),
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: MiniStat(
                              label: '周累计成交',
                              value: '¥ 4,417,600',
                              trend: 0.062,
                            ),
                          ),
                          Expanded(
                            child: MiniStat(
                              label: '周累计订单',
                              value: '138,420',
                              trend: 0.041,
                            ),
                          ),
                          Expanded(
                            child: MiniStat(
                              label: '峰值时段',
                              value: '20:00 - 22:00',
                            ),
                          ),
                          Expanded(
                            child: MiniStat(
                              label: '履约时效',
                              value: '11.6 小时',
                              trend: -0.05,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                right: Panel(
                  title: '渠道占比',
                  subtitle: '按成交额统计',
                  icon: Icons.donut_small_outlined,
                  trailing: WeDropdown<String>.builder(
                    alignRight: true,
                    items: const [
                      WeDropdownItem(
                        'gmv',
                        '按成交额',
                        icon: Icons.payments_outlined,
                      ),
                      WeDropdownItem(
                        'orders',
                        '按订单数',
                        icon: Icons.receipt_long_outlined,
                      ),
                      WeDropdownItem(
                        'uv',
                        '按访客',
                        icon: Icons.people_outline,
                        divided: true,
                      ),
                    ],
                    onSelected: (v) => WeMessage.info(context, '切换统计口径：$v'),
                    builder: (context, open) => WeButton(
                      text: '成交额',
                      trailingIcon: Icons.expand_more_rounded,
                      variant: WeButtonVariant.text,
                      size: SizeEnum.small,
                      onPressed: open,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: DonutChart(
                          slices: kChannelShare,
                          centerTitle: '全渠道成交',
                          centerValue: '74.9万',
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final c in kChannelShare)
                        LegendDot(
                          color: c.color,
                          name: c.name,
                          value: '${c.value.toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 品类 + 待办 ─────────────────────────────────────────
              _TwoColumn(
                twoUp: twoUp,
                leftFlex: 3,
                rightFlex: 2,
                left: Panel(
                  title: '品类销售额',
                  subtitle: '近 7 天',
                  icon: Icons.category_outlined,
                  trailing: const Tag(
                    '共 6 个一级品类',
                    theme: TagThemeEnum.light,
                    type: SemanticEnum.info,
                    size: SizeEnum.small,
                  ),
                  child: Column(
                    children: [
                      for (final c in kCategorySales)
                        CategoryBar(
                          name: c.name,
                          value: c.value,
                          max: kCategorySales.first.value,
                          color: Color.lerp(
                            colors.primary,
                            colors.success,
                            kCategorySales.indexOf(c) / kCategorySales.length,
                          )!,
                        ),
                    ],
                  ),
                ),
                right: Panel(
                  title: '今日待办',
                  subtitle: '按紧急程度排序',
                  icon: Icons.checklist_rounded,
                  trailing: WeButton(
                    text: '全部处理',
                    variant: WeButtonVariant.plain,
                    size: SizeEnum.small,
                    onPressed: _dispatchTodos,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < kTodos.length; i++)
                        _TodoRow(
                          todo: kTodos[i],
                          done: _done.contains(i),
                          onToggle: (v) => setState(() {
                            v ? _done.add(i) : _done.remove(i);
                          }),
                        ),
                      const SizedBox(height: 4),
                      WeProgress(
                        percentage: _done.length / kTodos.length * 100,
                        status: _done.length == kTodos.length
                            ? SemanticEnum.success
                            : null,
                        strokeWidth: 6,
                        format: (p) => '${_done.length}/${kTodos.length}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 热销榜 ──────────────────────────────────────────────
              Panel(
                title: '热销商品 TOP 5',
                subtitle: '按近 7 天销量排序',
                icon: Icons.local_fire_department_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WeSwitch(
                      value: _rankLoading,
                      size: SizeEnum.small,
                      activeText: '骨架屏',
                      onChanged: (v) => setState(() => _rankLoading = v),
                    ),
                    const SizedBox(width: 14),
                    WeSwitch(
                      value: _rankEmpty,
                      size: SizeEnum.small,
                      type: SemanticEnum.warning,
                      activeText: '空数据',
                      onChanged: (v) => setState(() => _rankEmpty = v),
                    ),
                  ],
                ),
                child: _rankLoading
                    ? Column(
                        children: [
                          for (int i = 0; i < 5; i++)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: WeSkeleton.avatarRow(),
                            ),
                        ],
                      )
                    : _rankEmpty
                    ? EmptyState(
                        title: '这个时间段没有成交',
                        description: '试试把时间范围放宽到近 30 天',
                        action: WeButton(
                          text: '查看近 30 天',
                          type: SemanticEnum.primary,
                          size: SizeEnum.small,
                          onPressed: () => setState(() => _rankEmpty = false),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < 5; i++)
                            _RankRow(
                              rank: i + 1,
                              product: kProducts[i],
                              ratio: kProducts[i].sold / kProducts[3].sold,
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              const WeDivider(
                text: '云集商城 · 商家运营后台　由 Widgets Easier 构建',
                dashed: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 宽屏两列、窄屏上下堆叠。
class _TwoColumn extends StatelessWidget {
  const _TwoColumn({
    required this.twoUp,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  final bool twoUp;
  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    if (!twoUp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, const SizedBox(height: 16), right],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: leftFlex, child: left),
          const SizedBox(width: 16),
          Expanded(flex: rightFlex, child: right),
        ],
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.todo,
    required this.done,
    required this.onToggle,
  });

  final ({String title, String desc, SemanticEnum type, IconData icon}) todo;
  final bool done;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final accent = done ? colors.placeholderText : colors.semantic(todo.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          WeAvatar(
            icon: todo.icon,
            size: 34,
            shape: WeAvatarShape.square,
            color: accent.withValues(alpha: 0.12),
            foregroundColor: accent,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeText(
                  todo.title,
                  role: done ? WeTextRole.placeholder : WeTextRole.primary,
                  bold: true,
                  strike: done,
                ),
                const SizedBox(height: 2),
                WeText(
                  todo.desc,
                  role: WeTextRole.secondary,
                  size: SizeEnum.small,
                ),
              ],
            ),
          ),
          WeCheckbox(value: done, type: todo.type, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.product,
    required this.ratio,
  });

  final int rank;
  final Product product;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final bool podium = rank <= 3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: podium
                  ? colors.warning.withValues(alpha: 0.16)
                  : colors.lightFill,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: podium ? colors.warning : colors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ProductThumb(emoji: product.emoji, tint: product.tint, size: 38),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.placeholderText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tag(
                      product.status.label,
                      type: product.status.semantic,
                      theme: TagThemeEnum.light,
                      size: SizeEnum.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: WeProgress(
                percentage: ratio.clamp(0.0, 1.0) * 100,
                color: product.tint,
                strokeWidth: 6,
                showText: false,
              ),
            ),
          ),
          WeRate(
            value: product.rating,
            readOnly: true,
            size: 14,
            allowHalf: true,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: WeStatistic(
              title: '',
              value: product.sold,
              suffix: '件',
              valueSize: 13,
              compact: true,
            ),
          ),
          SizedBox(
            width: 84,
            child: Text(
              '¥${product.price.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, color: colors.regularText),
            ),
          ),
        ],
      ),
    );
  }
}
