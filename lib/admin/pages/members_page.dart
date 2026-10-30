import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_data.dart';
import '../widgets/charts.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 会员运营：分层、成长值、流失预警与定向触达。
class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  static const List<({String name, double value, Color color})> _tiers = [
    (name: '黑钻会员', value: 3.2, color: Color(0xFF6C7BFF)),
    (name: '白金会员', value: 9.8, color: Color(0xFF3FC8B0)),
    (name: '黄金会员', value: 21.4, color: Color(0xFFFFC53D)),
    (name: '白银会员', value: 30.1, color: Color(0xFFFF8A4C)),
    (name: '普通会员', value: 35.5, color: Color(0xFFB0B6C3)),
  ];

  Set<Member> _picked = {};
  bool _onlyRisk = false;
  String _keyword = '';
  int _tab = 0;

  static Color tierColor(String level) => switch (level) {
    '黑钻会员' => const Color(0xFF6C7BFF),
    '白金会员' => const Color(0xFF3FC8B0),
    '黄金会员' => const Color(0xFFFFC53D),
    '白银会员' => const Color(0xFFFF8A4C),
    _ => const Color(0xFFB0B6C3),
  };

  List<Member> get _visible => kMembers.where((m) {
    if (_onlyRisk && !m.risk) return false;
    if (_keyword.isNotEmpty && !m.name.contains(_keyword)) return false;
    return true;
  }).toList();

  Future<void> _sendCoupon() async {
    if (_picked.isEmpty) {
      WeMessage.warning(context, '先在下面勾选要触达的会员');
      return;
    }
    final bool ok = await WeMessageBox.confirm(
      context,
      '将向选中的 ${_picked.length} 位会员发放「会员日通用券」，'
      '预计触达成本 ¥${_picked.length * 60}。',
      title: '定向发券',
      confirmText: '确认发放',
      type: SemanticEnum.primary,
    );
    if (!ok || !mounted) return;

    WeNotification.show(
      context,
      title: '发放成功',
      message: '${_picked.length} 张券已进入会员卡包。',
      type: SemanticEnum.success,
    );
    setState(() => _picked = {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: LayoutBuilder(
        builder: (context, box) {
          final bool twoUp = box.maxWidth > 1020;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WePageHeader(
                title: '会员运营',
                description: '共 186.4 万会员，近 30 天净增 4.2 万',
                actions: [
                  WeButton(
                    text: '会员规则',
                    icon: Icons.rule_rounded,
                    variant: WeButtonVariant.plain,
                    size: SizeEnum.small,
                    onPressed: () => BottomSheets.showInfoSheet(
                      context,
                      noImage: true,
                      title: '会员成长规则',
                      message:
                          '成长值 = 实付金额 ×1 + 有效评价 ×20 + 连续签到 ×5。'
                          '每自然年结算一次等级，降级保护期 90 天。',
                      buttonText: '知道了',
                      type: SemanticEnum.info,
                      onTapDismiss: () => Navigator.of(context).pop(),
                    ),
                  ),
                  WeButton(
                    text: '定向发券',
                    icon: Icons.card_giftcard_rounded,
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    onPressed: _sendCoupon,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 四个统计 ─────────────────────────────────────────
              WeCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: WeStatistic(
                        title: '会员总数',
                        value: 1864000,
                        suffix: '人',
                        trend: 0.023,
                        trendLabel: '较上月',
                      ),
                    ),
                    const SizedBox(height: 48, child: WeDivider.vertical()),
                    Expanded(
                      child: WeStatistic(
                        title: '付费会员',
                        value: 241300,
                        suffix: '人',
                        trend: 0.061,
                        trendLabel: '较上月',
                        valueColor: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 48, child: WeDivider.vertical()),
                    const Expanded(
                      child: WeStatistic(
                        title: '会员客单价',
                        value: 386.4,
                        prefix: '¥',
                        trend: -0.012,
                        trendLabel: '较上月',
                      ),
                    ),
                    const SizedBox(height: 48, child: WeDivider.vertical()),
                    Expanded(
                      child: WeStatistic(
                        title: '流失预警',
                        value: 12840,
                        suffix: '人',
                        trend: 0.087,
                        trendLabel: '较上月',
                        valueColor: colors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 概况 ──────────────────────────────────────────────
              _TwoUp(
                twoUp: twoUp,
                leftFlex: 2,
                rightFlex: 3,
                left: Panel(
                  title: '会员分层',
                  subtitle: '按当前等级占比',
                  icon: Icons.workspace_premium_outlined,
                  child: Column(
                    children: [
                      const Center(
                        child: DonutChart(
                          slices: _tiers,
                          centerTitle: '总会员数',
                          centerValue: '186.4万',
                          size: 160,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final t in _tiers)
                        LegendDot(
                          color: t.color,
                          name: t.name,
                          value: '${t.value}%',
                        ),
                    ],
                  ),
                ),
                right: Panel(
                  title: '会员权益位',
                  subtitle: '买家端「我的 - 会员中心」头图',
                  icon: Icons.image_outlined,
                  trailing: const Tag(
                    '生效中',
                    type: SemanticEnum.success,
                    theme: TagThemeEnum.light,
                    size: SizeEnum.small,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WeImage(
                        provider: const AssetImage('assets/example-img.png'),
                        height: 140,
                        fit: BoxFit.cover,
                        radius: BorderRadius.circular(10),
                        preview: true,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: MiniStat(label: '头图曝光', value: '86.2 万'),
                          ),
                          const Expanded(
                            child: MiniStat(
                              label: '点击率',
                              value: '11.4%',
                              trend: 0.008,
                            ),
                          ),
                          const Expanded(
                            child: MiniStat(
                              label: '开卡转化',
                              value: '3.7%',
                              trend: -0.003,
                            ),
                          ),
                          Expanded(
                            child: MiniStat(
                              label: '续费率',
                              value: '68.9%',
                              valueColor: colors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const AlertBanner(
                        type: SemanticEnum.info,
                        title: '素材提醒',
                        message: '当前头图已投放 42 天，建议在会员日前更换一版。',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 会员列表 ─────────────────────────────────────────
              Panel(
                title: '高价值与流失预警会员',
                subtitle: '勾选后可以批量发券或转入人工回访',
                icon: Icons.groups_outlined,
                padding: EdgeInsets.zero,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WeSwitch(
                      value: _onlyRisk,
                      size: SizeEnum.small,
                      type: SemanticEnum.danger,
                      activeText: '只看流失预警',
                      onChanged: (v) => setState(() => _onlyRisk = v),
                    ),
                    const SizedBox(width: 12),
                    SearchField(
                      hint: '搜索会员昵称',
                      width: 190,
                      size: SizeEnum.small,
                      onChanged: (v) => setState(() => _keyword = v),
                    ),
                  ],
                ),
                slivers: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: WeTabs(
                      index: _tab,
                      type: WeTabsType.card,
                      size: SizeEnum.small,
                      onChanged: (i) => setState(() => _tab = i),
                      tabs: const [
                        WeTab('列表', icon: Icons.table_rows_outlined),
                        WeTab('卡片', icon: Icons.grid_view_rounded),
                      ],
                    ),
                  ),
                ],
                footer: Row(
                  children: [
                    WeText(
                      _picked.isEmpty ? '未选择会员' : '已选择 ${_picked.length} 位会员',
                      role: WeTextRole.secondary,
                      size: SizeEnum.small,
                    ),
                    if (_picked.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      WeAvatarGroup(
                        size: 26,
                        max: 5,
                        avatars: [
                          for (final m in _picked)
                            WeAvatar(
                              text: m.name.characters.first,
                              color: tierColor(m.level),
                            ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    WeButtonGroup(
                      size: SizeEnum.small,
                      variant: WeButtonVariant.plain,
                      children: [
                        WeButton(
                          text: '导出名单',
                          icon: Icons.download_outlined,
                          onPressed: () => WeMessage.success(context, '名单已导出'),
                        ),
                        WeButton(
                          text: '人工回访',
                          icon: Icons.support_agent_rounded,
                          onPressed: () => WeMessage.info(context, '已转入客服工单'),
                        ),
                        WeButton(
                          text: '加入人群包',
                          icon: Icons.group_add_outlined,
                          onPressed: () => WeMessage.success(context, '已加入人群包'),
                        ),
                      ],
                    ),
                  ],
                ),
                child: _tab == 0 ? _table(colors) : _cards(colors),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _table(WeColorScheme colors) {
    return WeTable<Member>(
      rows: _visible,
      selectable: true,
      selected: _picked,
      onSelectionChanged: (s) => setState(() => _picked = s),
      rowHeight: 62,
      striped: true,
      empty: const EmptyState(
        title: '没有匹配的会员',
        description: '换个关键词，或者关掉「只看流失预警」',
        icon: Icons.person_search_outlined,
      ),
      columns: [
        WeColumn(
          title: '会员',
          flex: 3,
          sortBy: (m) => m.name,
          cell: (_, m) => Row(
            children: [
              WeAvatar(
                text: m.name.characters.first,
                color: tierColor(m.level),
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: WeText(
                            m.name,
                            role: WeTextRole.primary,
                            bold: true,
                            truncate: true,
                          ),
                        ),
                        if (m.risk) ...[
                          const SizedBox(width: 6),
                          const Tag(
                            '流失预警',
                            type: SemanticEnum.danger,
                            theme: TagThemeEnum.light,
                            size: SizeEnum.small,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Tag(
                      m.level,
                      color: tierColor(m.level),
                      theme: TagThemeEnum.plain,
                      size: SizeEnum.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WeColumn.text(
          '累计订单',
          (m) => '${m.orders} 单',
          flex: 2,
          sortBy: (m) => m.orders,
        ),
        WeColumn(
          title: '累计消费',
          flex: 2,
          sortBy: (m) => m.spend,
          cell: (_, m) => WeStatistic(
            title: '',
            value: m.spend,
            prefix: '¥',
            precision: 0,
            valueSize: 14,
            compact: true,
          ),
        ),
        WeColumn(
          title: '成长值',
          flex: 3,
          sortBy: (m) => m.growth,
          cell: (_, m) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: WeProgress(
              percentage: m.growth * 100,
              color: tierColor(m.level),
              strokeWidth: 8,
            ),
          ),
        ),
        WeColumn(
          title: '最近活跃',
          flex: 2,
          align: Alignment.centerRight,
          cell: (_, m) => WeText(
            m.lastSeen,
            type: m.risk ? SemanticEnum.danger : null,
            role: WeTextRole.placeholder,
            size: SizeEnum.small,
          ),
        ),
      ],
    );
  }

  Widget _cards(WeColorScheme colors) {
    final list = _visible;
    if (list.isEmpty) {
      return const EmptyState(
        title: '没有匹配的会员',
        description: '换个关键词，或者关掉「只看流失预警」',
        icon: Icons.person_search_outlined,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final m in list)
            SizedBox(
              width: 260,
              child: WeCard(
                shadow: WeCardShadow.hover,
                padding: const EdgeInsets.all(14),
                onTap: () => setState(() {
                  final next = {..._picked};
                  next.contains(m) ? next.remove(m) : next.add(m);
                  _picked = next;
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        WeAvatar(
                          text: m.name.characters.first,
                          color: tierColor(m.level),
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WeText(
                                m.name,
                                role: WeTextRole.primary,
                                bold: true,
                              ),
                              const SizedBox(height: 3),
                              Tag(
                                m.level,
                                color: tierColor(m.level),
                                theme: TagThemeEnum.plain,
                                size: SizeEnum.small,
                              ),
                            ],
                          ),
                        ),
                        WeCheckbox(
                          value: _picked.contains(m),
                          onChanged: (v) => setState(() {
                            final next = {..._picked};
                            v ? next.add(m) : next.remove(m);
                            _picked = next;
                          }),
                        ),
                      ],
                    ),
                    const WeDivider(margin: EdgeInsets.symmetric(vertical: 12)),
                    Row(
                      children: [
                        Expanded(
                          child: MiniStat(label: '订单', value: '${m.orders}'),
                        ),
                        Expanded(
                          child: MiniStat(
                            label: '消费',
                            value: '¥${m.spend.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    WeProgress(
                      percentage: m.growth * 100,
                      color: tierColor(m.level),
                      strokeWidth: 6,
                      format: (p) => '${p.round()}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: colors.placeholderText,
                        ),
                        const SizedBox(width: 4),
                        WeText(
                          m.lastSeen,
                          type: m.risk ? SemanticEnum.danger : null,
                          role: WeTextRole.placeholder,
                          size: SizeEnum.small,
                        ),
                        const Spacer(),
                        if (m.risk)
                          const WeBadge(
                            dot: true,
                            child: WeText('待回访', size: SizeEnum.small),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TwoUp extends StatelessWidget {
  const _TwoUp({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 16),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}
