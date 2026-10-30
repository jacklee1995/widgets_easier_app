import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_data.dart';
import '../widgets/panel.dart';

/// 营销中心：优惠券投放、活动配置与玩法规则。
class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final CounterInputController _perUser = CounterInputController(
    initialValue: 2,
  );
  final CounterInputController _budget = CounterInputController(
    initialValue: 50,
  );

  double _discount = 8.5;
  String _kind = 'discount';
  bool _stackable = true;
  final Set<String> _channels = {'小程序商城', 'App 商城'};
  final List<String> _crowds = ['近 30 天下单', '加购未付款', '沉睡 90 天'];
  final Set<String> _paused = {};

  @override
  void dispose() {
    _perUser.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _submitCampaign() async {
    final bool ok = await WeMessageBox.confirm(
      context,
      '${_discount.toStringAsFixed(1)} 折，'
      '投放到 ${_channels.length} 个渠道，'
      '预算 ${_budget.value.toStringAsFixed(1)} 万元。确认提交？',
      title: '提交投放',
      confirmText: '确认提交',
      cancelText: '再改改',
      type: SemanticEnum.primary,
    );
    if (!ok || !mounted) return;

    WeNotification.show(
      context,
      title: '活动已提交',
      message: '风控复核通过后自动开始投放。',
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
          final int cols = box.maxWidth > 1180
              ? 4
              : box.maxWidth > 760
              ? 2
              : 1;
          final double cardWidth = (box.maxWidth - (cols - 1) * 16) / cols;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WePageHeader(
                title: '营销中心',
                description: '优惠券、秒杀与拼团的投放配置，实时看核销率',
                actions: [
                  WeButton(
                    text: '玩法模板',
                    icon: Icons.auto_awesome_mosaic_outlined,
                    variant: WeButtonVariant.plain,
                    size: SizeEnum.small,
                    onPressed: () => WeMessage.info(context, '共 18 套行业模板'),
                  ),
                  WeButton(
                    text: '新建活动',
                    icon: Icons.add_rounded,
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        Color.lerp(colors.primary, colors.fatal, 0.5)!,
                      ],
                    ),
                    onPressed: () => WeNotification.show(
                      context,
                      position: WeNotificationPosition.bottomRight,
                      title: '新建活动',
                      message: '选择玩法后即可配置人群、库存与投放渠道。',
                      type: SemanticEnum.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 优惠券：四种斜面边框当券面 ────────────────────────
              Row(
                children: [
                  const WeText(
                    '在投优惠券',
                    role: WeTextRole.primary,
                    bold: true,
                    size: SizeEnum.large,
                  ),
                  const SizedBox(width: 8),
                  WeBadge(
                    value: kCoupons.length - _paused.length,
                    type: SemanticEnum.success,
                  ),
                  const SizedBox(width: 8),
                  if (_paused.isNotEmpty)
                    WeText(
                      '${_paused.length} 张已停投',
                      role: WeTextRole.placeholder,
                      size: SizeEnum.small,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const WeText(
                '券面用了库里的四种斜面边框：inset / outset / groove / ridge；右上角的开关可以停投。',
                role: WeTextRole.secondary,
                size: SizeEnum.small,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (int i = 0; i < kCoupons.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: _CouponCard(
                        coupon: kCoupons[i],
                        bevel: WeBevelStyle.values[i % 4],
                        active: !_paused.contains(kCoupons[i].name),
                        onToggle: (on) => setState(() {
                          on
                              ? _paused.remove(kCoupons[i].name)
                              : _paused.add(kCoupons[i].name);
                        }),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 活动配置 ──────────────────────────────────────────
              LayoutBuilder(
                builder: (context, inner) {
                  final bool twoUp = inner.maxWidth > 1020;
                  final config = Panel(
                    title: '会员日活动配置',
                    subtitle: '改动实时预览，保存后 5 分钟内生效',
                    trailing: const Tag(
                      '草稿',
                      type: SemanticEnum.warning,
                      theme: TagThemeEnum.light,
                      size: SizeEnum.small,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('活动玩法', '按钮式单选，切换后下方表单联动'),
                        WeRadioGroup<String>(
                          value: _kind,
                          style: WeRadioStyle.button,
                          size: SizeEnum.small,
                          onChanged: (v) => setState(() => _kind = v),
                          options: const [
                            WeRadioOption('discount', '折扣券'),
                            WeRadioOption('cash', '满减券'),
                            WeRadioOption('flash', '限时秒杀'),
                            WeRadioOption('group', '拼团', disabled: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('折扣力度', '拖动调整，1 折最狠，10 折即原价'),
                        WeSlider(
                          value: _discount,
                          min: 1,
                          max: 10,
                          step: 0.5,
                          showStops: true,
                          formatTooltip: (v) => '${v.toStringAsFixed(1)} 折',
                          onChanged: (v) => setState(() => _discount = v),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: '每人限领',
                                hint: '张',
                                child: CounterInput(
                                  controller: _perUser,
                                  size: SizeEnum.small,
                                  minValue: 1,
                                  maxValue: 10,
                                  textFieldWidth: 48,
                                  type: SemanticEnum.primary,
                                  onMaxOverflow: () =>
                                      WeMessage.warning(context, '每人最多领 10 张'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _Field(
                                label: '发放预算',
                                hint: '万元',
                                child: CounterInput(
                                  controller: _budget,
                                  size: SizeEnum.small,
                                  minValue: 0,
                                  maxValue: 500,
                                  step: 2.5,
                                  decimals: 1,
                                  textFieldWidth: 58,
                                  type: SemanticEnum.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('投放渠道', '至少选一个'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in const [
                              '小程序商城',
                              'App 商城',
                              '抖音小店',
                              '线下门店',
                              '企业采购',
                            ])
                              CheckTag(
                                c,
                                size: SizeEnum.small,
                                showCheckIcon: true,
                                checked: _channels.contains(c),
                                onChanged: (on) => setState(() {
                                  on ? _channels.add(c) : _channels.remove(c);
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('目标人群', '点标签上的叉可以移除，回车可以新增'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final c in _crowds)
                              Tag(
                                c,
                                id: c,
                                size: SizeEnum.small,
                                type: SemanticEnum.info,
                                theme: TagThemeEnum.light,
                                closable: true,
                                onClose: (id) =>
                                    setState(() => _crowds.remove(id)),
                              ),
                            SizedBox(
                              width: 150,
                              child: Tag(
                                '',
                                size: SizeEnum.small,
                                editable: true,
                                shrink: false,
                                restoreAfterSubmitted: true,
                                onSubmitted: (v) {
                                  if (v.trim().isEmpty) return;
                                  setState(() => _crowds.add(v.trim()));
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            WeSwitch(
                              value: _stackable,
                              size: SizeEnum.small,
                              inlinePrompt: true,
                              activeText: '叠',
                              inactiveText: '否',
                              onChanged: (v) => setState(() => _stackable = v),
                            ),
                            const SizedBox(width: 10),
                            WeText(
                              _stackable ? '允许与平台券叠加使用' : '不与其他优惠叠加',
                              role: WeTextRole.regular,
                              size: SizeEnum.small,
                            ),
                          ],
                        ),
                        const WeDivider(
                          margin: EdgeInsets.symmetric(vertical: 16),
                        ),
                        Row(
                          children: [
                            WeButton(
                              text: '保存草稿',
                              variant: WeButtonVariant.plain,
                              size: SizeEnum.small,
                              onPressed: () =>
                                  WeMessage.success(context, '草稿已保存'),
                            ),
                            const SizedBox(width: 10),
                            WeButton(
                              text: '提交投放',
                              icon: Icons.send_rounded,
                              type: SemanticEnum.primary,
                              size: SizeEnum.small,
                              onPressed: _submitCampaign,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  final rules = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Panel(
                        title: '玩法规则',
                        subtitle: '会同步展示在买家端的活动说明里',
                        icon: Icons.menu_book_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _RuleHeading('参与条件'),
                            Write.paragraph(
                              '活动期间，注册满 7 天且近 90 天有过成交的会员，可在会员日当天领取专属折扣券。',
                            ),
                            Write.orderedList([
                              Write.listItem('每个账号每场活动最多领取 2 张；'),
                              Write.listItem('折扣券与平台券可叠加，与店铺满减互斥；'),
                              Write.listItem('退款后券不返还，以订单实付金额为准。'),
                            ]),
                            const SizedBox(height: 14),
                            const WeAlert(
                              type: SemanticEnum.warning,
                              title: '风控提示',
                              description:
                                  '同设备超过 3 个账号领券会触发拦截；异常核销会在 T+1 对账时冻结结算金额。',
                              closable: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Panel(
                        title: '活动节奏',
                        subtitle: '预热 → 正式 → 返场',
                        icon: Icons.timeline_rounded,
                        child: WeTimeline(
                          items: [
                            WeTimelineItem(
                              title: '预热期',
                              description: '首页楼层曝光，会员可提前领券',
                              timestamp: '09-25 10:00',
                              type: SemanticEnum.success,
                              icon: Icons.check_rounded,
                            ),
                            WeTimelineItem(
                              title: '正式开卖',
                              description: '券可用，秒杀楼层每 2 小时一场',
                              timestamp: '09-28 00:00',
                              type: SemanticEnum.primary,
                              hollow: true,
                            ),
                            WeTimelineItem(
                              title: '返场',
                              description: '未核销券延长 48 小时',
                              timestamp: '10-03 00:00',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (!twoUp) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [config, const SizedBox(height: 16), rules],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: config),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: rules),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── 楼层权重：四档阴影 ────────────────────────────────
              const Panel(
                title: '首页活动楼层',
                subtitle: '权重越高的楼层投影越重，对应库里的四档阴影组件',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _FloorCard(
                      level: 'P0 主推位',
                      desc: '首屏轮播，日均曝光 210 万',
                      shadow: _ShadowLevel.dark,
                    ),
                    _FloorCard(
                      level: 'P1 次推位',
                      desc: '第二屏通栏，日均曝光 96 万',
                      shadow: _ShadowLevel.basic,
                    ),
                    _FloorCard(
                      level: 'P2 常规位',
                      desc: '品类楼层，日均曝光 44 万',
                      shadow: _ShadowLevel.light,
                    ),
                    _FloorCard(
                      level: 'P3 兜底位',
                      desc: '猜你喜欢，日均曝光 18 万',
                      shadow: _ShadowLevel.lighter,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── 优惠券卡片 ──────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.bevel,
    required this.active,
    required this.onToggle,
  });

  final Coupon coupon;
  final WeBevelStyle bevel;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final accent = active
        ? colors.semantic(coupon.type)
        : colors.placeholderText;

    final shape = WeBevelBorder(
      style: bevel,
      width: 6,
      lightColor: accent.withValues(alpha: 0.45),
      darkColor: accent.withValues(alpha: 0.85),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0.72,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: shape, color: colors.baseBackground),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    coupon.face,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: WeText(
                      coupon.rule,
                      role: WeTextRole.secondary,
                      size: SizeEnum.small,
                    ),
                  ),
                  WeSwitch(
                    value: active,
                    size: SizeEnum.small,
                    type: coupon.type,
                    onChanged: onToggle,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: WeText(
                      coupon.name,
                      role: WeTextRole.primary,
                      bold: true,
                      truncate: true,
                    ),
                  ),
                  if (!active)
                    const Tag(
                      '已停投',
                      size: SizeEnum.small,
                      type: SemanticEnum.info,
                      theme: TagThemeEnum.light,
                    ),
                ],
              ),
              const SizedBox(height: 3),
              WeText(
                '有效期至 ${coupon.deadline}',
                role: WeTextRole.placeholder,
                size: SizeEnum.small,
              ),
              const SizedBox(height: 12),
              WeProgress(
                percentage: coupon.usage * 100,
                color: accent,
                strokeWidth: 6,
                textInside: false,
                format: (p) => '核销 ${p.toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Tag(
                    bevel.name,
                    size: SizeEnum.small,
                    type: coupon.type,
                    theme: TagThemeEnum.light,
                  ),
                  const Spacer(),
                  WeText(
                    '${coupon.used} / ${coupon.issued}',
                    role: WeTextRole.placeholder,
                    size: SizeEnum.small,
                  ),
                  const SizedBox(width: 6),
                  WeButton.icon(
                    Icons.bar_chart_rounded,
                    variant: WeButtonVariant.text,
                    size: SizeEnum.small,
                    tooltip: '核销明细',
                    onPressed: () =>
                        WeMessage.info(context, '「${coupon.name}」核销明细开发中'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 小件 ────────────────────────────────────────────────────────────────

/// 规则面板里的小标题。Write 自带的 headerN 有固定配色，这里换成跟主题走的。
class _RuleHeading extends StatelessWidget {
  const _RuleHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.title, this.hint);

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(fontSize: 11.5, color: colors.placeholderText),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.hint, required this.child});

  final String label;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(child: child),
            const SizedBox(width: 8),
            Text(
              hint,
              style: TextStyle(fontSize: 11.5, color: colors.secondaryText),
            ),
          ],
        ),
      ],
    );
  }
}

enum _ShadowLevel { dark, basic, light, lighter }

class _FloorCard extends StatelessWidget {
  const _FloorCard({
    required this.level,
    required this.desc,
    required this.shadow,
  });

  final String level;
  final String desc;
  final _ShadowLevel shadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final body = Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.baseBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lighterBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 11.5, color: colors.secondaryText),
          ),
          const SizedBox(height: 10),
          Text(
            switch (shadow) {
              _ShadowLevel.dark => 'DarkShadow',
              _ShadowLevel.basic => 'BasicShadow',
              _ShadowLevel.light => 'LightShadow',
              _ShadowLevel.lighter => 'LighterShadow',
            },
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: colors.placeholderText,
            ),
          ),
        ],
      ),
    );

    return switch (shadow) {
      _ShadowLevel.dark => DarkShadow(child: body),
      _ShadowLevel.basic => BasicShadow(child: body),
      _ShadowLevel.light => LightShadow(child: body),
      _ShadowLevel.lighter => LighterShadow(child: body),
    };
  }
}
