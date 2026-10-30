import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';
import 'package:widgets_easier_privacy_guard/widgets_easier_privacy_guard.dart';

import '../../theme_mode.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 系统设置：店铺信息、通知策略、安全设置与外观。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CounterInputController _autoConfirm = CounterInputController(
    initialValue: 7,
  );
  final CounterInputController _safetyStock = CounterInputController(
    initialValue: 50,
  );

  bool _smsNotice = true;
  Set<String> _faq = {'color'};
  bool _weeklyReport = true;
  bool _riskNotice = false;
  bool _guardScreenshot = false;
  bool _syncing = false;
  String _region = '广东省 · 深圳市 · 南山区';
  String _settle = 'T+1';
  String? _category = 'home';
  Set<String> _channels = {'inbox', 'sms'};

  static const List<Color> _brandOptions = [
    Color(0xFF409EFF),
    Color(0xFF6C7BFF),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFFE11D48),
    Color(0xFF8B5CF6),
  ];

  @override
  void dispose() {
    _autoConfirm.dispose();
    _safetyStock.dispose();
    super.dispose();
  }

  void _verifyThenDanger() {
    final colors = context.weColors;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.overlayBackground,
        title: const WeText(
          '安全校验',
          role: WeTextRole.primary,
          bold: true,
          size: SizeEnum.large,
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WeAlert(
                type: SemanticEnum.danger,
                title: '清空测试订单属于高危操作，请先完成滑块验证。',
                closable: false,
              ),
              const SizedBox(height: 14),
              // 底图拉不到时 WeCaptcha 会退化成生成图案，断网也能验证。
              WeCaptcha.network(
                'https://picsum.photos/id/1080/720/240',
                height: 160,
                maxAttempts: 3,
                onSuccess: () {
                  Navigator.of(dialogContext).pop();
                  WeNotification.show(
                    context,
                    title: '校验通过',
                    message: '测试订单已清空，正式订单不受影响。',
                    type: SemanticEnum.success,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncChannels() async {
    setState(() => _syncing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _syncing = false);
    WeNotification.success(
      context,
      title: '同步完成',
      message: '已同步 5 个渠道的商品、库存与价格',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return WeLoading(
      loading: _syncing,
      text: '正在同步渠道',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: LayoutBuilder(
          builder: (context, box) {
            final bool twoUp = box.maxWidth > 1020;

            final shop = Panel(
              title: '店铺信息',
              subtitle: '对外展示的基础资料',
              icon: Icons.storefront_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Row(
                    label: '店铺名称',
                    child: WeInput(
                      initialValue: '云集商城官方旗舰店',
                      width: 280,
                      size: SizeEnum.small,
                      maxLength: 20,
                      showWordLimit: true,
                      clearable: true,
                    ),
                  ),
                  const _Row(
                    label: '客服电话',
                    child: WeInput(
                      initialValue: '400 800 1234',
                      width: 280,
                      size: SizeEnum.small,
                      prepend: Text('+86'),
                      prefixIcon: Icons.phone_outlined,
                    ),
                  ),
                  _Row(
                    label: '经营品类',
                    child: WeSelect<String>(
                      value: _category,
                      width: 280,
                      size: SizeEnum.small,
                      clearable: true,
                      hint: '选择主营品类',
                      onChanged: (v) => setState(() => _category = v),
                      options: const [
                        WeSelectOption(
                          'home',
                          '家用电器',
                          icon: Icons.kitchen_outlined,
                        ),
                        WeSelectOption(
                          'digital',
                          '数码配件',
                          icon: Icons.headphones_outlined,
                        ),
                        WeSelectOption(
                          'beauty',
                          '美妆个护',
                          icon: Icons.spa_outlined,
                        ),
                        WeSelectOption(
                          'food',
                          '食品生鲜',
                          icon: Icons.egg_alt_outlined,
                        ),
                        WeSelectOption(
                          'sport',
                          '运动户外',
                          icon: Icons.directions_bike_outlined,
                          disabled: true,
                        ),
                      ],
                    ),
                  ),
                  _Row(
                    label: '默认发货地',
                    child: Row(
                      children: [
                        Flexible(
                          child: WeText(
                            _region,
                            role: WeTextRole.primary,
                            truncate: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        WeLink(
                          '修改',
                          icon: Icons.edit_outlined,
                          onTap: () async {
                            final picked = await BottomSheets.showCascadeSheet(
                              context,
                              cancelButtonText: '取消',
                              confirmButtonText: '确定',
                              items: _regionTree,
                            );
                            if (picked != null &&
                                picked.isNotEmpty &&
                                mounted) {
                              setState(
                                () => _region = picked
                                    .where((e) => e.isNotEmpty)
                                    .join(' · '),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  _Row(
                    label: '结算周期',
                    child: WeRadioGroup<String>(
                      value: _settle,
                      size: SizeEnum.small,
                      onChanged: (v) => setState(() => _settle = v),
                      options: const [
                        WeRadioOption('T+1', 'T+1'),
                        WeRadioOption('T+7', 'T+7'),
                        WeRadioOption('month', '月结'),
                      ],
                    ),
                  ),
                  _Row(
                    label: '自动确认收货',
                    hint: '天',
                    child: CounterInput(
                      controller: _autoConfirm,
                      size: SizeEnum.small,
                      minValue: 3,
                      maxValue: 30,
                      textFieldWidth: 48,
                      type: SemanticEnum.primary,
                    ),
                  ),
                  _Row(
                    label: '安全库存阈值',
                    hint: '件，低于该值触发预警',
                    child: CounterInput(
                      controller: _safetyStock,
                      size: SizeEnum.small,
                      minValue: 0,
                      maxValue: 1000,
                      step: 10,
                      textFieldWidth: 56,
                      type: SemanticEnum.warning,
                    ),
                  ),
                  const WeDivider(margin: EdgeInsets.only(bottom: 16)),
                  Row(
                    children: [
                      WeButton(
                        text: '同步到全渠道',
                        icon: Icons.sync_rounded,
                        type: SemanticEnum.primary,
                        size: SizeEnum.small,
                        loading: _syncing,
                        onPressed: _syncChannels,
                      ),
                      const SizedBox(width: 10),
                      WeButton(
                        text: '清空测试订单',
                        icon: Icons.delete_sweep_outlined,
                        type: SemanticEnum.danger,
                        variant: WeButtonVariant.plain,
                        size: SizeEnum.small,
                        onPressed: _verifyThenDanger,
                      ),
                    ],
                  ),
                ],
              ),
            );

            final notice = Panel(
              title: '通知与提醒',
              subtitle: '决定哪些事件会打扰到你',
              icon: Icons.notifications_none_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Toggle(
                    title: '短信提醒',
                    desc: '大额订单与退款申请实时短信通知',
                    value: _smsNotice,
                    onChanged: (v) => setState(() => _smsNotice = v),
                  ),
                  _Toggle(
                    title: '经营周报',
                    desc: '每周一早上 9 点发送到邮箱',
                    value: _weeklyReport,
                    onChanged: (v) => setState(() => _weeklyReport = v),
                  ),
                  _Toggle(
                    title: '风控拦截',
                    desc: '命中风控规则时二次确认后再通知（beforeChange 演示）',
                    value: _riskNotice,
                    type: SemanticEnum.danger,
                    beforeChange: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => ConfirmDialog(
                          noImage: true,
                          title: '切换风控通知',
                          message: '风控通知量较大，确认要${_riskNotice ? '关闭' : '开启'}吗？',
                          confirmButtonText: '确认',
                          cancelButtonText: '取消',
                          type: SemanticEnum.danger,
                          onTapConfirm: () => Navigator.of(ctx).pop(true),
                          onTapCancel: () => Navigator.of(ctx).pop(false),
                        ),
                      );
                      return ok ?? false;
                    },
                    onChanged: (v) => setState(() => _riskNotice = v),
                  ),
                  const SizedBox(height: 6),
                  const _SectionLabel('通知渠道', '至少保留一个'),
                  WeCheckboxGroup<String>(
                    value: _channels,
                    size: SizeEnum.small,
                    min: 1,
                    onChanged: (v) => setState(() => _channels = v),
                    options: const {
                      'inbox': '站内信',
                      'sms': '短信',
                      'mail': '邮件',
                      'wecom': '企业微信',
                    },
                  ),
                  const WeDivider(margin: EdgeInsets.symmetric(vertical: 16)),
                  const _SectionLabel('通知样式预览', '顶部消息、四角通知与三处轻提示，点一下看效果'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      WeButton(
                        text: '成功消息',
                        type: SemanticEnum.success,
                        size: SizeEnum.small,
                        variant: WeButtonVariant.plain,
                        onPressed: () =>
                            WeMessage.success(context, '结算完成，货款已打款'),
                      ),
                      WeButton(
                        text: '警告消息',
                        type: SemanticEnum.warning,
                        size: SizeEnum.small,
                        variant: WeButtonVariant.plain,
                        onPressed: () =>
                            WeMessage.warning(context, '库存告急：轻氧胶囊咖啡机仅剩 46 件'),
                      ),
                      WeButton(
                        text: '错误消息',
                        type: SemanticEnum.danger,
                        size: SizeEnum.small,
                        variant: WeButtonVariant.plain,
                        onPressed: () => WeMessage.error(
                          context,
                          '抖音小店授权已过期',
                          closable: true,
                        ),
                      ),
                      WeButton(
                        text: '普通消息',
                        type: SemanticEnum.info,
                        size: SizeEnum.small,
                        variant: WeButtonVariant.plain,
                        onPressed: () => WeMessage.info(context, '后台已更新到 v2.6'),
                      ),
                      WeButton(
                        text: '右上通知',
                        type: SemanticEnum.success,
                        size: SizeEnum.small,
                        onPressed: () => WeNotification.show(
                          context,
                          title: '结算完成',
                          message: '本期货款 ¥1,284,600 已打款至对公账户。',
                          type: SemanticEnum.success,
                        ),
                      ),
                      WeButton(
                        text: '左上通知',
                        type: SemanticEnum.warning,
                        size: SizeEnum.small,
                        onPressed: () => WeNotification.show(
                          context,
                          position: WeNotificationPosition.topLeft,
                          title: '库存告急',
                          message: '「轻氧胶囊咖啡机 Mini」仅剩 46 件。',
                          type: SemanticEnum.warning,
                        ),
                      ),
                      WeButton(
                        text: '右下通知',
                        type: SemanticEnum.danger,
                        size: SizeEnum.small,
                        onPressed: () => WeNotification.show(
                          context,
                          position: WeNotificationPosition.bottomRight,
                          title: '同步失败',
                          message: '抖音小店授权已过期，请重新绑定。',
                          type: SemanticEnum.danger,
                        ),
                      ),
                      WeButton(
                        text: '左下通知',
                        type: SemanticEnum.info,
                        size: SizeEnum.small,
                        onPressed: () => WeNotification.show(
                          context,
                          position: WeNotificationPosition.bottomLeft,
                          title: '版本更新',
                          message: '后台已更新到 v2.6，新增品类排行看板。',
                          type: SemanticEnum.info,
                        ),
                      ),
                      WeButton(
                        text: '顶部提示',
                        variant: WeButtonVariant.text,
                        size: SizeEnum.small,
                        onPressed: () => WeMessage.success(context, '设置已保存'),
                      ),
                      WeButton(
                        text: '居中提示',
                        variant: WeButtonVariant.text,
                        size: SizeEnum.small,
                        onPressed: () => WeMessage.info(context, '操作成功'),
                      ),
                      WeButton(
                        text: '底部提示',
                        variant: WeButtonVariant.text,
                        size: SizeEnum.small,
                        onPressed: () => WeMessage.info(context, '已复制订单号到剪贴板'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WePageHeader(
                  title: '系统设置',
                  description: '店铺信息、通知策略、外观与安全',
                  actions: [
                    WeButton(
                      text: '恢复默认',
                      icon: Icons.restart_alt_rounded,
                      variant: WeButtonVariant.plain,
                      size: SizeEnum.small,
                      onPressed: () async {
                        final bool ok = await WeMessageBox.confirm(
                          context,
                          '所有自定义配置会被重置为平台默认值，历史数据不受影响。',
                          title: '恢复默认设置',
                          confirmText: '恢复默认',
                          type: SemanticEnum.warning,
                        );
                        if (ok && context.mounted) {
                          WeMessage.success(context, '已恢复默认设置');
                        }
                      },
                    ),
                    WeButton(
                      text: '保存设置',
                      icon: Icons.save_outlined,
                      type: SemanticEnum.primary,
                      size: SizeEnum.small,
                      onPressed: () => WeMessage.success(context, '设置已保存'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (twoUp)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: shop),
                      const SizedBox(width: 16),
                      Expanded(child: notice),
                    ],
                  )
                else ...[
                  shop,
                  const SizedBox(height: 16),
                  notice,
                ],
                const SizedBox(height: 16),

                // ── 外观 ──────────────────────────────────────────────
                Panel(
                  title: '外观',
                  subtitle: '主色会通过 WeTheme 传导到所有组件，暗色模式同步生效',
                  icon: Icons.palette_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('品牌主色', '换色后整站按钮、链接、进度条即时跟随'),
                      ValueListenableBuilder<Color>(
                        valueListenable: brandColor,
                        builder: (context, current, _) => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final c in _brandOptions)
                              _Swatch(
                                color: c,
                                selected: c.toARGB32() == current.toARGB32(),
                                onTap: () => brandColor.value = c,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _SectionLabel('配色模式', '跟随系统 / 浅色 / 深色'),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeMode,
                        builder: (context, mode, _) => WeSegmented<ThemeMode>(
                          value: mode,
                          size: SizeEnum.small,
                          onChanged: (m) => themeMode.value = m,
                          options: const [
                            WeSegmentedOption(
                              ThemeMode.system,
                              '跟随系统',
                              icon: Icons.brightness_auto_rounded,
                            ),
                            WeSegmentedOption(
                              ThemeMode.light,
                              '浅色',
                              icon: Icons.light_mode_outlined,
                            ),
                            WeSegmentedOption(
                              ThemeMode.dark,
                              '深色',
                              icon: Icons.dark_mode_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _SectionLabel(
                        '色阶预览',
                        'WeColorShades 由主色派生的 light-3/5/7/8/9 与 dark-2',
                      ),
                      Row(
                        children: [
                          for (final entry in <(String, Color)>[
                            ('dark-2', colors.dark(SemanticEnum.primary)),
                            ('base', colors.primary),
                            ('light-3', colors.light(SemanticEnum.primary, 3)),
                            ('light-5', colors.light(SemanticEnum.primary, 5)),
                            ('light-7', colors.light(SemanticEnum.primary, 7)),
                            ('light-8', colors.light(SemanticEnum.primary, 8)),
                            ('light-9', colors.light(SemanticEnum.primary, 9)),
                          ])
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 36,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: entry.$2,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  WeText(
                                    entry.$1,
                                    role: WeTextRole.placeholder,
                                    size: SizeEnum.small,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 安全 ──────────────────────────────────────────────
                Panel(
                  title: '账号与数据安全',
                  subtitle: '看板涉及经营数据，建议在公共场合开启隐私保护',
                  icon: Icons.security_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeDescriptions(
                        columns: 3,
                        bordered: true,
                        size: SizeEnum.small,
                        items: [
                          const WeDescriptionItem('登录账号', 'jcLee95'),
                          const WeDescriptionItem('角色', '超级管理员'),
                          WeDescriptionItem(
                            '两步验证',
                            '',
                            child: Row(
                              children: [
                                const Tag(
                                  '已开启',
                                  type: SemanticEnum.success,
                                  theme: TagThemeEnum.light,
                                  size: SizeEnum.small,
                                ),
                                const SizedBox(width: 8),
                                WeLink(
                                  '重新绑定',
                                  fontSize: 12,
                                  onTap: () =>
                                      WeMessage.info(context, '打开绑定向导'),
                                ),
                              ],
                            ),
                          ),
                          const WeDescriptionItem(
                            '最近登录',
                            '今天 08:42 · 深圳 · Chrome',
                          ),
                          WeDescriptionItem(
                            '登录密码',
                            '',
                            span: 2,
                            child: Row(
                              children: [
                                const WeText(
                                  '上次修改于 86 天前',
                                  role: WeTextRole.secondary,
                                  size: SizeEnum.small,
                                ),
                                const SizedBox(width: 8),
                                WeLink(
                                  '修改密码',
                                  type: SemanticEnum.warning,
                                  fontSize: 12,
                                  onTap: () =>
                                      WeMessage.warning(context, '请先完成两步验证'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Toggle(
                        title: '防截屏与后台模糊',
                        desc:
                            '来自独立插件 widgets_easier_privacy_guard。'
                            'Android 会设置 FLAG_SECURE，各平台切后台时都会给内容加高斯模糊。',
                        value: _guardScreenshot,
                        type: SemanticEnum.success,
                        onChanged: (v) => setState(() => _guardScreenshot = v),
                      ),
                      const SizedBox(height: 4),
                      // PrivacyGuard 包住要保护的区域，这里保护的是营收快照。
                      PrivacyGuard(
                        preventScreenshot: _guardScreenshot,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.lighterBorder),
                            color: colors.lightFill,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _guardScreenshot
                                    ? Icons.shield_rounded
                                    : Icons.shield_outlined,
                                size: 22,
                                color: _guardScreenshot
                                    ? colors.success
                                    : colors.placeholderText,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: MiniStat(
                                  label: '本月待结算货款',
                                  value: '¥ 12,846,000.00',
                                ),
                              ),
                              const Expanded(
                                child: MiniStat(
                                  label: '保证金余额',
                                  value: '¥ 500,000.00',
                                ),
                              ),
                              Tag(
                                _guardScreenshot ? '已保护' : '未保护',
                                type: _guardScreenshot
                                    ? SemanticEnum.success
                                    : SemanticEnum.secondary,
                                theme: TagThemeEnum.light,
                                size: SizeEnum.small,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const AlertBanner(
                        type: SemanticEnum.info,
                        title: '平台限制',
                        message: 'iOS 没有公开 API 可以阻止截屏，插件在该平台只保留切后台模糊。',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Panel(
                  title: '常见问题',
                  icon: Icons.help_outline,
                  child: WeCollapse(
                    expanded: _faq,
                    accordion: true,
                    onChanged: (s) => setState(() => _faq = s),
                    items: const [
                      WeCollapseItem(
                        name: 'color',
                        title: '改了主色为什么有的按钮没变？',
                        child: WeText(
                          '只有走 WeTheme 的 WeButton 会跟随。文档页里尚未迁完的 SemanticButton 仍用旧色板。',
                        ),
                      ),
                      WeCollapseItem(
                        name: 'dark',
                        title: '暗色模式切不干净？',
                        child: WeText(
                          'WeTheme.dark() 覆盖组件色，Material 原生控件还需 ThemeData.brightness。',
                        ),
                      ),
                      WeCollapseItem(
                        name: 'sync',
                        title: '全渠道同步要多久？',
                        child: WeText('示例里是 1.4 秒的假延迟。真实环境取决于各平台开放接口。'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const List<Map<String, dynamic>> _regionTree = [
  {
    'label': '广东省',
    'children': [
      {
        'label': '深圳市',
        'children': [
          {'label': '南山区'},
          {'label': '福田区'},
          {'label': '宝安区'},
        ],
      },
      {
        'label': '广州市',
        'children': [
          {'label': '天河区'},
          {'label': '白云区'},
        ],
      },
    ],
  },
  {
    'label': '浙江省',
    'children': [
      {
        'label': '杭州市',
        'children': [
          {'label': '余杭区'},
          {'label': '滨江区'},
        ],
      },
      {
        'label': '宁波市',
        'children': [
          {'label': '鄞州区'},
        ],
      },
    ],
  },
  {
    'label': '江苏省',
    'children': [
      {
        'label': '南京市',
        'children': [
          {'label': '江宁区'},
          {'label': '鼓楼区'},
        ],
      },
    ],
  },
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, this.hint);

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          WeText(title, role: WeTextRole.primary, bold: true),
          const SizedBox(width: 8),
          Expanded(
            child: WeText(
              hint,
              role: WeTextRole.placeholder,
              size: SizeEnum.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 110, child: WeText(label, role: WeTextRole.regular)),
          Flexible(child: child),
          if (hint != null) ...[
            const SizedBox(width: 8),
            WeText(hint!, role: WeTextRole.placeholder, size: SizeEnum.small),
          ],
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.desc,
    required this.value,
    required this.onChanged,
    this.type,
    this.beforeChange,
  });

  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final SemanticEnum? type;
  final Future<bool> Function()? beforeChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeText(title, role: WeTextRole.primary, bold: true),
                const SizedBox(height: 2),
                WeText(desc, role: WeTextRole.secondary, size: SizeEnum.small),
              ],
            ),
          ),
          const SizedBox(width: 12),
          WeSwitch(
            value: value,
            type: type ?? SemanticEnum.primary,
            beforeChange: beforeChange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colors.primaryText : Colors.transparent,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
            : null,
      ),
    );
  }
}
