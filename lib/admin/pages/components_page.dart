import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_upload.dart';

/// 组件总览：对照 Element Plus 的清单，每个 We 组件一张卡，附最小用法。
class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  int _section = 0;
  WePlatformFit? _fitFilter;
  bool _phonePreview = false;

  // 表单示例的状态。
  String _input = '';
  String? _select = 'a';
  Set<String> _checks = {'sms'};
  String _radio = 'mid';
  bool _switch = true;
  double _rate = 3.5;
  double _slider = 42;
  (double, double) _range = (20, 80);
  bool _regionBusy = false;
  final WeCaptchaController _captcha = WeCaptchaController();
  Set<String> _multi = {'新品', '热卖', '包邮'};
  String? _city;
  String? _user;
  final WeFormController _demoForm = WeFormController();
  String _account = '';
  String? _role;
  final WePopperController _popper = WePopperController();
  DateTime? _date = DateTime(2026, 9, 20);
  DateTimeRange? _period;
  DateTime _wheelDay = DateTime(2026, 9, 18);
  DateTimeRange? _sheetRange;
  List<String>? _region = const ['zj', 'hz', 'xh'];
  List<String>? _regionAny;

  static const List<WeCascaderOption<String>> _regions = [
    WeCascaderOption(
      'zj',
      '浙江',
      children: [
        WeCascaderOption(
          'hz',
          '杭州',
          children: [
            WeCascaderOption('xh', '西湖区'),
            WeCascaderOption('bj', '滨江区'),
            WeCascaderOption('yh', '余杭区'),
          ],
        ),
        WeCascaderOption(
          'nb',
          '宁波',
          children: [
            WeCascaderOption('yz', '鄞州区'),
            WeCascaderOption('bl', '北仑区'),
          ],
        ),
      ],
    ),
    WeCascaderOption(
      'js',
      '江苏',
      children: [
        WeCascaderOption(
          'nj',
          '南京',
          children: [
            WeCascaderOption('gl', '鼓楼区'),
            WeCascaderOption('xw', '玄武区'),
          ],
        ),
        WeCascaderOption('sz', '苏州', children: [WeCascaderOption('gs', '姑苏区')]),
      ],
    ),
    WeCascaderOption(
      'gd',
      '广东',
      children: [
        WeCascaderOption('gz', '广州', children: [WeCascaderOption('th', '天河区')]),
        WeCascaderOption(
          'szh',
          '深圳',
          children: [WeCascaderOption('ns', '南山区')],
        ),
      ],
    ),
    WeCascaderOption('xz', '西藏（暂停发货）', disabled: true),
  ];
  DateTime? _calendarDay = DateTime(2026, 9, 20);
  final WeUploadController _docs = WeUploadController([
    WeUploadFile.uploaded(name: '商品上架规范.pdf', size: 820 * 1024),
  ]);
  final WeUploadController _photos = WeUploadController();

  // 数据示例的状态。
  int _page = 3;
  int _pageSize = 20;
  Set<_Sku> _picked = {};
  double _progress = 64;

  // 导航示例的状态。
  int _tab = 0;
  String? _treeSelected;
  Set<String> _treeChecked = {};
  Set<String> _treeMulti = {};
  String _treeQuery = '';
  Set<String> _collapse = {'a'};

  static const List<WeTreeNode<String>> _demoTree = [
    WeTreeNode(
      'food',
      '食品',
      children: [
        WeTreeNode('snack', '零食'),
        WeTreeNode('tea', '茶饮'),
        WeTreeNode('wine', '酒水（未开通）', disabled: true),
      ],
    ),
    WeTreeNode(
      'digital',
      '数码',
      children: [WeTreeNode('phone', '手机'), WeTreeNode('audio', '耳机音响')],
    ),
    WeTreeNode('home', '家居'),
  ];

  static const List<WeImageSource> _demoGallery = [
    WeImageSource.provider(AssetImage('assets/example-img.png')),
    WeImageSource.provider(AssetImage('assets/local-image.png')),
    WeImageSource.provider(AssetImage('assets/jclee95.png')),
  ];
  String _seg = 'week';
  String _menu = 'products';
  int _step = 1;
  int _tabbar = 0;
  int _tabbarReselect = 0;

  static const List<WeTabbarItem> _tabbarItems = [
    WeTabbarItem('首页', Icons.home_outlined, activeIcon: Icons.home_rounded),
    WeTabbarItem(
      '分类',
      Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    WeTabbarItem(
      '消息',
      Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      badge: 8,
    ),
    WeTabbarItem(
      '我的',
      Icons.person_outline,
      activeIcon: Icons.person,
      dot: true,
    ),
  ];

  static const List<_Sku> _skus = [
    _Sku('SKU-001', '轻氧胶囊咖啡机', 1299, 4.9),
    _Sku('SKU-002', '无界降噪耳机', 1699, 4.7),
    _Sku('SKU-003', '云感记忆枕', 299, 4.5),
  ];

  @override
  void dispose() {
    _captcha.dispose();
    _popper.dispose();
    _docs.dispose();
    _photos.dispose();
    super.dispose();
  }

  // 模拟远程用户搜索，演示 WeSelect.remoteMethod 的加载与空状态。
  static Future<List<WeSelectOption<String>>> _searchUsers(String q) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    const all = ['张晓雨', '张一鸣', '李思远', '王可可', '赵子墨', '陈安安'];
    return [
      for (final n in all)
        if (q.isEmpty || n.contains(q))
          WeSelectOption(n, n, icon: Icons.person_outline),
    ];
  }

  Future<String?> _accountTaken(Object? v) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return v == 'admin' ? '账号 admin 已被占用' : null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WePageHeader(
            title: '组件总览',
            description: '对照 Element Plus 的组件清单，每个 We 组件一张卡，附最小用法',
            tag: const Tag(
              '40+',
              type: SemanticEnum.primary,
              theme: TagThemeEnum.light,
              size: SizeEnum.small,
            ),
            actions: [
              WeButton(
                text: '查看 CHANGELOG',
                icon: Icons.history_rounded,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () => WeMessage.info(
                  context,
                  'packages/widgets_easier/CHANGELOG.md',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _platformBar(),
          const SizedBox(height: 12),
          _GalleryScope(
            filter: _fitFilter,
            phone: _phonePreview,
            child: WeTabs(
              index: _section,
              type: WeTabsType.borderCard,
              onChanged: (i) => setState(() => _section = i),
              tabs: const [
                WeTab('基础', icon: Icons.widgets_outlined),
                WeTab('表单', icon: Icons.edit_note_rounded),
                WeTab('数据', icon: Icons.table_chart_outlined),
                WeTab('导航', icon: Icons.explore_outlined),
                WeTab('反馈', icon: Icons.notifications_active_outlined),
              ],
              children: [
                _basics(),
                _form(),
                _data(),
                _navigation(),
                _feedback(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 平台筛选、图例和「按手机预览」开关。
  Widget _platformBar() {
    final colors = context.weColors;
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        WeSegmented<WePlatformFit?>(
          size: SizeEnum.small,
          value: _fitFilter,
          onChanged: (v) => setState(() => _fitFilter = v),
          options: [
            const WeSegmentedOption(null, '全部', icon: Icons.apps_rounded),
            for (final f in WePlatformFit.values)
              WeSegmentedOption(f, f.label, icon: f.icon),
          ],
        ),
        for (final f in WePlatformFit.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FitTag(f),
              const SizedBox(width: 6),
              Text(switch (f) {
                WePlatformFit.universal => '手机和电脑都好用',
                WePlatformFit.desktop => '要鼠标键盘或宽屏',
                WePlatformFit.mobile => '为手指和窄屏设计',
              }, style: TextStyle(fontSize: 12, color: colors.secondaryText)),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeSwitch(
              key: const ValueKey('phone-preview'),
              value: _phonePreview,
              size: SizeEnum.small,
              onChanged: (v) => setState(() => _phonePreview = v),
            ),
            const SizedBox(width: 8),
            Text(
              '按手机预览（390 宽、触屏尺寸）',
              style: TextStyle(fontSize: 13, color: colors.regularText),
            ),
          ],
        ),
      ],
    );
  }

  // ── 基础 ──────────────────────────────────────────────────────────────

  Widget _basics() {
    final colors = context.weColors;
    return _Grid(
      children: [
        _Demo(
          name: 'WeButton',
          we: 'we-button',
          fit: WePlatformFit.universal,
          desc:
              'solid / plain / text / link 四种变体，round、circle、loading、disabled',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in SemanticEnum.values)
                    WeButton(
                      text: t.name,
                      type: t,
                      size: SizeEnum.small,
                      onPressed: () {},
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  WeButton(
                    text: 'plain',
                    variant: WeButtonVariant.plain,
                    size: SizeEnum.small,
                    onPressed: () {},
                  ),
                  WeButton(
                    text: 'text',
                    variant: WeButtonVariant.text,
                    size: SizeEnum.small,
                    onPressed: () {},
                  ),
                  WeButton(
                    text: 'link',
                    variant: WeButtonVariant.link,
                    size: SizeEnum.small,
                    onPressed: () {},
                  ),
                  WeButton(
                    text: 'round',
                    round: true,
                    size: SizeEnum.small,
                    onPressed: () {},
                  ),
                  WeButton.icon(
                    Icons.search_rounded,
                    circle: true,
                    size: SizeEnum.small,
                    onPressed: () {},
                  ),
                  const WeButton(
                    text: 'loading',
                    loading: true,
                    size: SizeEnum.small,
                  ),
                  const WeButton(text: 'disabled', size: SizeEnum.small),
                ],
              ),
              const SizedBox(height: 8),
              WeButtonGroup(
                size: SizeEnum.small,
                children: [
                  WeButton(
                    text: '上一页',
                    icon: Icons.chevron_left_rounded,
                    onPressed: () {},
                  ),
                  WeButton(
                    text: '下一页',
                    trailingIcon: Icons.chevron_right_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const _Demo(
          name: 'WeText',
          we: 'we-text',
          fit: WePlatformFit.universal,
          desc:
              '主题化文本：role 决定颜色，type 覆盖语义色，bold / italic / strike / mark / truncate',
          child: Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              WeText('primary', role: WeTextRole.primary),
              WeText('regular'),
              WeText('secondary', role: WeTextRole.secondary),
              WeText('placeholder', role: WeTextRole.placeholder),
              WeText('success', type: SemanticEnum.success),
              WeText('danger', type: SemanticEnum.danger),
              WeText('bold', bold: true),
              WeText('italic', italic: true),
              WeText('strike', strike: true),
              WeText('mark', mark: true),
            ],
          ),
        ),
        _Demo(
          name: 'WeLink',
          we: 'we-link',
          fit: WePlatformFit.universal,
          desc: '行内链接，悬停下划线，可带图标与语义色',
          child: Wrap(
            spacing: 14,
            children: [
              WeLink('默认链接', onTap: () {}),
              WeLink('成功', type: SemanticEnum.success, onTap: () {}),
              WeLink('警告', type: SemanticEnum.warning, onTap: () {}),
              WeLink('带图标', icon: Icons.edit_outlined, onTap: () {}),
              WeLink(
                '外链',
                trailingIcon: Icons.open_in_new_rounded,
                underline: false,
                onTap: () {},
              ),
              const WeLink('禁用', disabled: true),
            ],
          ),
        ),
        _Demo(
          name: 'WeTag / CheckTag',
          we: 'we-tag / we-check-tag',
          fit: WePlatformFit.universal,
          desc: 'plain / light / dark 三种主题，可关闭、可编辑；CheckTag 可勾选',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in [
                SemanticEnum.primary,
                SemanticEnum.success,
                SemanticEnum.warning,
                SemanticEnum.danger,
                SemanticEnum.info,
              ])
                Tag(
                  t.name,
                  type: t,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
              const Tag(
                'dark',
                type: SemanticEnum.primary,
                theme: TagThemeEnum.dark,
                size: SizeEnum.small,
              ),
              Tag(
                'closable',
                type: SemanticEnum.info,
                closable: true,
                size: SizeEnum.small,
                onClose: (_) {},
              ),
              CheckTag(
                '已勾选',
                checked: true,
                showCheckIcon: true,
                size: SizeEnum.small,
                onChanged: (_) {},
              ),
              CheckTag(
                '未勾选',
                checked: false,
                size: SizeEnum.small,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeBadge',
          we: 'we-badge',
          fit: WePlatformFit.universal,
          desc: '数字、小圆点、超过 max 显示 99+；可包裹任意子组件或独立使用',
          child: Wrap(
            spacing: 22,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WeBadge(
                value: 5,
                child: WeButton(
                  text: '消息',
                  size: SizeEnum.small,
                  variant: WeButtonVariant.plain,
                  onPressed: () {},
                ),
              ),
              WeBadge(
                value: 128,
                max: 99,
                child: WeButton(
                  text: '订单',
                  size: SizeEnum.small,
                  variant: WeButtonVariant.plain,
                  onPressed: () {},
                ),
              ),
              WeBadge(
                dot: true,
                child: WeButton.icon(
                  Icons.notifications_none_rounded,
                  size: SizeEnum.small,
                  variant: WeButtonVariant.plain,
                  onPressed: () {},
                ),
              ),
              const WeBadge(value: 'new', type: SemanticEnum.success),
              const WeBadge(value: 3, type: SemanticEnum.warning),
            ],
          ),
        ),
        _Demo(
          name: 'WeAvatar / WeAvatarGroup',
          we: 'we-avatar',
          fit: WePlatformFit.universal,
          desc: '图片、文字、图标三种回退，圆形与方形，分组重叠并统计溢出',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const WeAvatar(text: '林', size: 36),
              WeAvatar(text: '周', size: 36, color: colors.success),
              const WeAvatar(
                icon: Icons.person_outline_rounded,
                size: 36,
                shape: WeAvatarShape.square,
              ),
              const WeAvatar(
                text: 'B',
                size: 36,
                border: true,
                shape: WeAvatarShape.square,
              ),
              WeAvatarGroup(
                size: 32,
                max: 4,
                avatars: [
                  for (final n in ['赵', '钱', '孙', '李', '周', '吴'])
                    WeAvatar(
                      text: n,
                      color: colors.light(SemanticEnum.primary, 3),
                    ),
                ],
              ),
            ],
          ),
        ),
        const _Demo(
          name: 'WeDivider',
          we: 'we-divider',
          fit: WePlatformFit.universal,
          desc: '水平 / 垂直，虚线，带文字（左 / 中 / 右）',
          child: Column(
            children: [
              WeDivider(
                text: '居中标题',
                margin: EdgeInsets.symmetric(vertical: 8),
              ),
              WeDivider(
                text: '左对齐',
                align: WeDividerAlign.start,
                dashed: true,
                margin: EdgeInsets.symmetric(vertical: 8),
              ),
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    WeText('订单'),
                    WeDivider.vertical(),
                    WeText('会员'),
                    WeDivider.vertical(),
                    WeText('营销'),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeImage',
          we: 'we-image',
          fit: WePlatformFit.universal,
          desc: '点任意一张从它开始预览：← → 翻页、滚轮 / + - 缩放、旋转、Esc 关闭；最后一张是加载失败的样子',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < _demoGallery.length; i++)
                WeImage(
                  provider: _demoGallery[i].provider,
                  width: 72,
                  height: 72,
                  radius: const BorderRadius.all(Radius.circular(8)),
                  preview: true,
                  previewList: _demoGallery,
                  initialIndex: i,
                ),
              const WeImage(
                src: '',
                width: 72,
                height: 72,
                radius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeCard',
          we: 'we-card',
          fit: WePlatformFit.universal,
          desc: '标题 / 副标题 / 图标 / 右侧操作 / 页脚，阴影 always · hover · never',
          child: Row(
            children: [
              const Expanded(
                child: WeCard(
                  title: 'always',
                  shadow: WeCardShadow.always,
                  padding: EdgeInsets.all(12),
                  headerPadding: EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: WeText('常驻阴影', size: SizeEnum.small),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WeCard(
                  title: 'hover',
                  shadow: WeCardShadow.hover,
                  padding: const EdgeInsets.all(12),
                  headerPadding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  extra: WeLink('操作', fontSize: 12, onTap: () {}),
                  child: const WeText('悬停出现', size: SizeEnum.small),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: WeCard(
                  title: 'never',
                  padding: EdgeInsets.all(12),
                  headerPadding: EdgeInsets.fromLTRB(12, 10, 12, 8),
                  footer: WeText(
                    '页脚',
                    role: WeTextRole.secondary,
                    size: SizeEnum.small,
                  ),
                  child: WeText('只有边框', size: SizeEnum.small),
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeStatistic',
          we: 'we-statistic',
          fit: WePlatformFit.universal,
          desc: '千分位、精度、前后缀、涨跌趋势，compact 模式可嵌进表格',
          child: Row(
            children: [
              const Expanded(
                child: WeStatistic(
                  title: '今日成交',
                  value: 748600,
                  prefix: '¥',
                  trend: 0.098,
                  trendLabel: '较昨日',
                ),
              ),
              Expanded(
                child: WeStatistic(
                  title: '退款率',
                  value: 2.14,
                  suffix: '%',
                  precision: 2,
                  trend: -0.004,
                  valueColor: colors.danger,
                ),
              ),
              const Expanded(
                child: WeStatistic(title: '在线人数', value: 12840, suffix: '人'),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeBevelBorder / 阴影',
          we: '—',
          fit: WePlatformFit.universal,
          desc: 'inset / outset / groove / ridge 四种 CSS 斜面边框，四档阴影',
          child: Row(
            children: [
              for (final s in WeBevelStyle.values) ...[
                Expanded(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: WeBevelBorder(
                        style: s,
                        width: 5,
                        lightColor: colors.light(SemanticEnum.primary, 5),
                        darkColor: colors.primary,
                      ),
                    ),
                    child: SizedBox(
                      height: 44,
                      child: Center(
                        child: WeText(s.name, size: SizeEnum.small),
                      ),
                    ),
                  ),
                ),
                if (s != WeBevelStyle.values.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── 表单 ──────────────────────────────────────────────────────────────

  Widget _form() {
    return _Grid(
      children: [
        _Demo(
          name: 'WeForm / WeFormItem / WeRule',
          we: 'we-form',
          fit: WePlatformFit.universal,
          desc: '标签对齐、必填星号、change / blur / 异步校验、出错自动染红字段；试试输入 admin',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeForm(
                controller: _demoForm,
                labelWidth: 72,
                size: SizeEnum.small,
                children: [
                  WeFormItem(
                    name: 'account',
                    label: '账号',
                    value: _account,
                    rules: [
                      const WeRule(required: true),
                      WeRule(
                        pattern: RegExp(r'^[a-z][a-z0-9_]{3,15}$'),
                        message: '小写字母开头，4-16 位',
                        trigger: WeRuleTrigger.blur,
                      ),
                      WeRule(
                        validator: _accountTaken,
                        trigger: WeRuleTrigger.blur,
                      ),
                    ],
                    onReset: () => setState(() => _account = ''),
                    child: WeInput(
                      hint: '登录账号',
                      prefixIcon: Icons.person_outline,
                      onChanged: (v) => setState(() => _account = v),
                    ),
                  ),
                  WeFormItem(
                    name: 'role',
                    label: '角色',
                    value: _role,
                    rules: const [WeRule(required: true, message: '请选择角色')],
                    onReset: () => setState(() => _role = null),
                    child: WeSelect<String>(
                      value: _role,
                      hint: '选择角色',
                      options: const [
                        WeSelectOption('admin', '超级管理员'),
                        WeSelectOption('ops', '运营'),
                        WeSelectOption('cs', '客服'),
                      ],
                      onChanged: (v) => setState(() => _role = v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 72),
                  WeButton(
                    text: '提交',
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    onPressed: () async {
                      if (await _demoForm.validate() && mounted) {
                        WeMessage.success(context, '校验通过');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  WeButton(
                    text: '重置',
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: _demoForm.resetFields,
                  ),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeInput',
          we: 'we-input',
          fit: WePlatformFit.universal,
          desc: '前后图标、prepend / append、清空、密码切换、字数限制、校验状态',
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              WeInput(
                hint: '搜索商品',
                prefixIcon: Icons.search_rounded,
                clearable: true,
                width: 200,
                size: SizeEnum.small,
                onChanged: (v) => setState(() => _input = v),
              ),
              const WeInput(
                hint: '密码',
                obscure: true,
                showPasswordToggle: true,
                width: 160,
                size: SizeEnum.small,
              ),
              const WeInput(
                hint: '网址',
                prepend: Text('https://'),
                append: Text('.com'),
                width: 260,
                size: SizeEnum.small,
              ),
              const WeInput(
                initialValue: '最多 10 字',
                maxLength: 10,
                showWordLimit: true,
                width: 160,
                size: SizeEnum.small,
              ),
              const WeInput(
                initialValue: '错误',
                status: SemanticEnum.danger,
                width: 120,
                size: SizeEnum.small,
              ),
              const WeInput(
                hint: '禁用',
                disabled: true,
                width: 120,
                size: SizeEnum.small,
              ),
              if (_input.isNotEmpty)
                WeText(
                  '输入：$_input',
                  role: WeTextRole.secondary,
                  size: SizeEnum.small,
                ),
            ],
          ),
        ),
        _Demo(
          name: 'WeDatePicker',
          we: 'we-date-picker',
          fit: WePlatformFit.universal,
          desc:
              '电脑上弹日历面板，可直接键入（2026-9-5 / 20260905）、↓ 进入面板方向键选日；手机上自动改成底部滚轮（打开「按手机预览」试试）；范围选择带快捷项',
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              WeDatePicker(
                value: _date,
                size: SizeEnum.small,
                disabledDate: (d) => d.isAfter(DateTime(2026, 9, 20)),
                onChanged: (d) => setState(() => _date = d),
              ),
              WeDatePicker.range(
                range: _period,
                size: SizeEnum.small,
                shortcuts: [
                  WeDateShortcut(
                    '最近一周',
                    () => DateTimeRange(
                      start: DateTime(2026, 9, 14),
                      end: DateTime(2026, 9, 20),
                    ),
                  ),
                  WeDateShortcut(
                    '本月',
                    () => DateTimeRange(
                      start: DateTime(2026, 9),
                      end: DateTime(2026, 9, 30),
                    ),
                  ),
                ],
                onChanged: (r) => setState(() => _period = r),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeDateWheel / WeDateSheet',
          we: 'van-date-picker',
          fit: WePlatformFit.mobile,
          desc:
              '年 / 月 / 日三列滚轮，手指上下拨；1 月 31 日拨到 2 月自动变 28 日；WeDateSheet 从底部弹出，带取消 / 确定，范围模式可切开始 / 结束',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: WeDateWheel(
                  value: _wheelDay,
                  itemExtent: 36,
                  disabledDate: (d) => d.weekday >= DateTime.saturday,
                  onChanged: (d) => setState(() => _wheelDay = d),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  WeButton(
                    text: '选日期',
                    icon: Icons.event_outlined,
                    size: SizeEnum.small,
                    onPressed: () async {
                      final d = await WeDateSheet.show(
                        context,
                        initial: _wheelDay,
                        title: '发货日期',
                      );
                      if (d != null) setState(() => _wheelDay = d);
                    },
                  ),
                  WeButton(
                    text: '选范围',
                    icon: Icons.date_range_outlined,
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: () async {
                      final r = await WeDateSheet.showRange(
                        context,
                        initial: _sheetRange,
                        title: '活动时间',
                      );
                      if (r != null) setState(() => _sheetRange = r);
                    },
                  ),
                  WeText(
                    '已选 ${weFormatDate(_wheelDay, 'yyyy-MM-dd')}'
                    '${_sheetRange == null ? '' : '，范围 ${weFormatDate(_sheetRange!.start, 'MM-dd')} 至 ${weFormatDate(_sheetRange!.end, 'MM-dd')}'}',
                    role: WeTextRole.secondary,
                    size: SizeEnum.small,
                  ),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeCascader',
          we: 'we-cascader',
          fit: WePlatformFit.desktop,
          desc: '逐列展开选路径；可搜索（显示完整路径）、任选一级（单选框）；←→↑↓ Enter 键盘操作',
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              WeCascader<String>(
                options: _regions,
                value: _region,
                size: SizeEnum.small,
                width: 240,
                clearable: true,
                filterable: true,
                hint: '发货地（可搜索）',
                onChanged: (v) => setState(() => _region = v),
              ),
              WeCascader<String>(
                options: _regions,
                value: _regionAny,
                size: SizeEnum.small,
                width: 200,
                checkStrictly: true,
                showAllLevels: false,
                expandTrigger: WeCascaderTrigger.hover,
                hint: '任选一级 / 悬停展开',
                onChanged: (v) => setState(() => _regionAny = v),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeSelect',
          we: 'we-select',
          fit: WePlatformFit.universal,
          desc: '单选 / 多选（折叠标签、上限）、可搜索、分组、远程搜索；↑↓ Enter Esc 键盘操作',
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              WeSelect<String>.multiple(
                values: _multi,
                width: 280,
                size: SizeEnum.small,
                hint: '营销标签',
                filterable: true,
                clearable: true,
                collapseTags: true,
                collapseTagsTooltip: true,
                maxCollapseTags: 2,
                multipleLimit: 4,
                onChanged: (v) => setState(() => _multi = v),
                options: const [
                  WeSelectOption('新品', '新品'),
                  WeSelectOption('热卖', '热卖'),
                  WeSelectOption('包邮', '包邮'),
                  WeSelectOption('限时折扣', '限时折扣'),
                  WeSelectOption('节日礼盒', '节日礼盒'),
                  WeSelectOption('低糖', '低糖'),
                ],
              ),
              WeSelect<String>(
                value: _city,
                width: 180,
                size: SizeEnum.small,
                hint: '发货仓（分组）',
                filterable: true,
                onChanged: (v) => setState(() => _city = v),
                groups: const [
                  WeSelectGroup('华东', [
                    WeSelectOption('sh', '上海仓'),
                    WeSelectOption('hz', '杭州仓'),
                  ]),
                  WeSelectGroup('华南', [
                    WeSelectOption('gz', '广州仓'),
                    WeSelectOption('sz', '深圳仓'),
                  ]),
                  WeSelectGroup('华北', [
                    WeSelectOption('bj', '北京仓'),
                    WeSelectOption('tj', '天津仓', disabled: true),
                  ]),
                ],
              ),
              WeSelect<String>(
                value: _user,
                width: 180,
                size: SizeEnum.small,
                hint: '远程搜索用户',
                clearable: true,
                remoteMethod: _searchUsers,
                onChanged: (v) => setState(() => _user = v),
              ),
              WeSelect<String>(
                value: _select,
                width: 200,
                size: SizeEnum.small,
                clearable: true,
                hint: '选择渠道',
                onChanged: (v) => setState(() => _select = v),
                options: const [
                  WeSelectOption(
                    'a',
                    '小程序商城',
                    icon: Icons.phone_iphone_rounded,
                  ),
                  WeSelectOption('b', 'App 商城', icon: Icons.apps_rounded),
                  WeSelectOption('c', '抖音小店', icon: Icons.music_note_rounded),
                  WeSelectOption(
                    'd',
                    '线下门店',
                    icon: Icons.store_outlined,
                    disabled: true,
                  ),
                ],
              ),
              WeSelect<String>(
                value: null,
                width: 160,
                size: SizeEnum.small,
                hint: '禁用',
                disabled: true,
                onChanged: (_) {},
                options: const [],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeTreeSelect',
          we: 'we-tree-select',
          fit: WePlatformFit.universal,
          desc: '单选点叶子即关、可搜索；多选只显示最上层的整组标签，超出折叠成 +N',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              WeTreeSelect<String>(
                width: 220,
                nodes: _demoTree,
                value: _treeSelected,
                filterable: true,
                clearable: true,
                onChanged: (v) => setState(() => _treeSelected = v),
              ),
              WeTreeSelect<String>.multiple(
                width: 280,
                nodes: _demoTree,
                values: _treeMulti,
                hint: '多选类目',
                collapseTags: true,
                clearable: true,
                onValuesChanged: (s) => setState(() => _treeMulti = s),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeCheckbox / WeCheckboxGroup',
          we: 'we-checkbox',
          fit: WePlatformFit.universal,
          desc: '半选、边框样式、分组 min / max 限制',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WeCheckbox(value: true, label: '选中', onChanged: (_) {}),
                  const SizedBox(width: 16),
                  WeCheckbox(value: null, label: '半选', onChanged: (_) {}),
                  const SizedBox(width: 16),
                  const WeCheckbox(
                    value: false,
                    label: '禁用',
                    disabled: true,
                    onChanged: null,
                  ),
                  const SizedBox(width: 16),
                  WeCheckbox(
                    value: true,
                    label: '带边框',
                    border: true,
                    size: SizeEnum.small,
                    onChanged: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              WeCheckboxGroup<String>(
                value: _checks,
                min: 1,
                max: 3,
                size: SizeEnum.small,
                border: true,
                onChanged: (v) => setState(() => _checks = v),
                options: const {
                  'inbox': '站内信',
                  'sms': '短信',
                  'mail': '邮件',
                  'wecom': '企微',
                },
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeRadioGroup',
          we: 'we-radio',
          fit: WePlatformFit.universal,
          desc: '圆点与按钮两种样式，可竖排',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeRadioGroup<String>(
                value: _radio,
                onChanged: (v) => setState(() => _radio = v),
                options: const [
                  WeRadioOption('low', '低'),
                  WeRadioOption('mid', '中'),
                  WeRadioOption('high', '高'),
                  WeRadioOption('x', '禁用', disabled: true),
                ],
              ),
              const SizedBox(height: 10),
              WeRadioGroup<String>(
                value: _radio,
                style: WeRadioStyle.button,
                size: SizeEnum.small,
                onChanged: (v) => setState(() => _radio = v),
                options: const [
                  WeRadioOption('low', '低'),
                  WeRadioOption('mid', '中'),
                  WeRadioOption('high', '高'),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeSwitch',
          we: 'we-switch',
          fit: WePlatformFit.universal,
          desc: '文字 / 图标标签、内嵌提示、加载态、beforeChange 拦截',
          child: Wrap(
            spacing: 18,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WeSwitch(
                value: _switch,
                onChanged: (v) => setState(() => _switch = v),
              ),
              WeSwitch(
                value: _switch,
                activeText: '开',
                inactiveText: '关',
                onChanged: (v) => setState(() => _switch = v),
              ),
              WeSwitch(
                value: _switch,
                inlinePrompt: true,
                activeIcon: Icons.check_rounded,
                inactiveIcon: Icons.close_rounded,
                onChanged: (v) => setState(() => _switch = v),
              ),
              WeSwitch(
                value: _switch,
                type: SemanticEnum.success,
                size: SizeEnum.small,
                onChanged: (v) => setState(() => _switch = v),
              ),
              WeSwitch(value: _switch, loading: true, onChanged: (_) {}),
              const WeSwitch(value: true, disabled: true, onChanged: null),
            ],
          ),
        ),
        _Demo(
          name: 'WeRate',
          we: 'we-rate',
          fit: WePlatformFit.universal,
          desc: '半星、只读、显示分值、每星文案',
          child: Wrap(
            spacing: 20,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WeRate(
                value: _rate,
                allowHalf: true,
                onChanged: (v) => setState(() => _rate = v),
              ),
              WeRate(
                value: _rate,
                allowHalf: true,
                showScore: true,
                readOnly: true,
              ),
              WeRate(
                value: _rate,
                texts: const ['失望', '一般', '满意', '惊喜', '超赞'],
                onChanged: (v) => setState(() => _rate = v),
              ),
              WeRate(
                value: 4,
                icon: Icons.favorite_rounded,
                color: context.weColors.danger,
                readOnly: true,
                size: 18,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeSlider',
          we: 'we-slider',
          fit: WePlatformFit.universal,
          desc: '步进、刻度、范围、旁路数字框，颜色走 WeTheme',
          wide: true,
          child: Column(
            children: [
              WeSlider(
                value: _slider,
                min: 0,
                max: 100,
                step: 1,
                showStops: true,
                showInput: true,
                marks: const [
                  WeSliderMark(0, '0'),
                  WeSliderMark(50, '50'),
                  WeSliderMark(100, '100'),
                ],
                onChanged: (v) => setState(() => _slider = v),
              ),
              const SizedBox(height: 8),
              WeSlider.range(
                values: _range,
                min: 0,
                max: 100,
                step: 5,
                onRangeChanged: (r) => setState(() => _range = r),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeUpload',
          we: 'we-upload',
          fit: WePlatformFit.universal,
          desc: '选文件与上传都由外部注入；类型 / 大小 / 数量限制、进度、失败重试、图片墙',
          wide: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WeUpload(
                  controller: _docs,
                  picker: mockUpload.pickDocuments,
                  uploader: mockUpload.upload,
                  accept: const ['.pdf', '.xlsx', '.docx'],
                  maxSize: 2 * 1024 * 1024,
                  limit: 4,
                  drag: true,
                  dragText: '点击从素材库取一个文件',
                  tip: 'pdf / xlsx / docx，不超过 2 MB，最多 4 个（营业执照扫描件 3.5 MB 会被拒）',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: WeUpload(
                  controller: _photos,
                  picker: mockUpload.pickImages,
                  uploader: mockUpload.upload,
                  multiple: true,
                  limit: 6,
                  accept: const ['image/*'],
                  listType: WeUploadListType.pictureCard,
                  cardSize: 80,
                  tip: '每次取 2 张，悬停卡片可预览、删除，失败的可重试',
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeCaptcha',
          we: '—',
          fit: WePlatformFit.universal,
          desc: '滑动拼图验证：缺口随机、失败抖动重试、次数限制、方向键可操作；无底图时用生成图案',
          wide: true,
          child: LayoutBuilder(
            builder: (context, box) {
              final Widget captcha = WeCaptcha(
                controller: _captcha,
                height: 150,
                maxAttempts: 3,
                onSuccess: () => WeMessage.success(context, '验证通过'),
              );
              final Widget side = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WeText('控制器', role: WeTextRole.primary, bold: true),
                  const SizedBox(height: 6),
                  const WeText(
                    'WeCaptchaController 暴露 refresh / reset 与 status，'
                    '表单提交前可以用 solved 判断是否已通过。',
                    role: WeTextRole.secondary,
                    size: SizeEnum.small,
                  ),
                  const SizedBox(height: 10),
                  WeButtonGroup(
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    children: [
                      WeButton(
                        text: '换一张',
                        icon: Icons.refresh_rounded,
                        onPressed: _captcha.refresh,
                      ),
                      WeButton(
                        text: '复位',
                        icon: Icons.restart_alt_rounded,
                        onPressed: _captcha.reset,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _captcha,
                    builder: (context, _) => Tag(
                      _captcha.status.name,
                      size: SizeEnum.small,
                      theme: TagThemeEnum.light,
                      type: _captcha.solved
                          ? SemanticEnum.success
                          : SemanticEnum.info,
                    ),
                  ),
                ],
              );
              if (box.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [captcha, const SizedBox(height: 16), side],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: captcha),
                  const SizedBox(width: 16),
                  Expanded(child: side),
                ],
              );
            },
          ),
        ),
        _Demo(
          name: 'CounterInput',
          we: 'we-input-number',
          fit: WePlatformFit.mobile,
          desc: '步进、小数位、范围、长按连续、键盘方向键、只读',
          child: Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              CounterInput(
                controller: CounterInputController(initialValue: 3),
                minValue: 1,
                maxValue: 10,
                size: SizeEnum.small,
              ),
              CounterInput(
                controller: CounterInputController(initialValue: 2.5),
                minValue: 0,
                maxValue: 100,
                step: 0.5,
                decimals: 1,
                size: SizeEnum.small,
                type: SemanticEnum.success,
              ),
              CounterInput(
                controller: CounterInputController(initialValue: -5),
                minValue: -20,
                maxValue: 20,
                step: 5,
                size: SizeEnum.small,
                type: SemanticEnum.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 数据 ──────────────────────────────────────────────────────────────

  static const Map<int, List<WeCalendarEvent>> _september = {
    1: [WeCalendarEvent('开学季大促', type: SemanticEnum.danger)],
    3: [WeCalendarEvent('选品会', time: '10:00')],
    8: [
      WeCalendarEvent('周会', time: '09:30'),
      WeCalendarEvent('供应商对账', type: SemanticEnum.warning),
    ],
    10: [
      WeCalendarEvent('教师节活动上线', type: SemanticEnum.success),
      WeCalendarEvent('直播彩排', time: '14:00'),
      WeCalendarEvent('复盘会', time: '17:00'),
      WeCalendarEvent('素材评审'),
      WeCalendarEvent('团建'),
    ],
    15: [WeCalendarEvent('周会', time: '09:30')],
    18: [WeCalendarEvent('中秋备货截止', type: SemanticEnum.warning)],
    22: [
      WeCalendarEvent('周会', time: '09:30'),
      WeCalendarEvent('大促预热', type: SemanticEnum.danger),
    ],
    25: [WeCalendarEvent('中秋节', type: SemanticEnum.success)],
    29: [WeCalendarEvent('国庆大促', type: SemanticEnum.danger)],
  };

  List<WeCalendarEvent> _eventsOf(DateTime d) =>
      d.year == 2026 && d.month == 9 ? _september[d.day] ?? const [] : const [];

  Widget _data() {
    final colors = context.weColors;
    return _Grid(
      children: [
        _Demo(
          name: 'WeCalendar',
          we: 'we-calendar',
          fit: WePlatformFit.desktop,
          desc: '日程看板：事件条、放不下时「还有 N 项」、窄屏收成圆点；点标题切年月，方向键 / PageUp / T 键盘导航',
          wide: true,
          child: SizedBox(
            height: 560,
            child: WeCalendar(
              value: _calendarDay,
              initialMonth: DateTime(2026, 9),
              showWeekNumber: true,
              onChanged: (d) => setState(() => _calendarDay = d),
              events: _eventsOf,
              onEventTap: (e, d) =>
                  WeMessage.info(context, '${weFormatDate(d)} · ${e.title}'),
              headerTrailing: WeButton(
                text: '新建日程',
                icon: Icons.add_rounded,
                size: SizeEnum.small,
                onPressed: () {},
              ),
            ),
          ),
        ),
        _Demo(
          name: 'WeTable',
          we: 'we-table',
          fit: WePlatformFit.desktop,
          desc: '列定义、行选择、排序、条纹、边框、悬停、空态 / 加载态、页脚',
          wide: true,
          child: WeTable<_Sku>(
            rows: _skus,
            selectable: true,
            selected: _picked,
            onSelectionChanged: (s) => setState(() => _picked = s),
            striped: true,
            bordered: true,
            size: SizeEnum.small,
            columns: [
              WeColumn.text('编号', (s) => s.id, width: 110, sortBy: (s) => s.id),
              WeColumn.text('名称', (s) => s.name, flex: 2),
              WeColumn(
                title: '售价',
                align: Alignment.centerRight,
                sortBy: (s) => s.price,
                cell: (_, s) => WeStatistic(
                  title: '',
                  value: s.price,
                  prefix: '¥',
                  precision: 0,
                  valueSize: 13,
                  compact: true,
                ),
              ),
              WeColumn(
                title: '评分',
                cell: (_, s) => WeRate(
                  value: s.rating,
                  readOnly: true,
                  allowHalf: true,
                  size: 14,
                ),
              ),
              WeColumn(
                title: '操作',
                width: 90,
                align: Alignment.centerRight,
                cell: (_, s) => WeLink(
                  '编辑',
                  fontSize: 12,
                  onTap: () => WeMessage.info(context, '编辑 ${s.id}'),
                ),
              ),
            ],
            footer: WeText(
              '已选 ${_picked.length} 行',
              role: WeTextRole.secondary,
              size: SizeEnum.small,
            ),
          ),
        ),
        _Demo(
          name: 'WePagination',
          we: 'we-pagination',
          fit: WePlatformFit.desktop,
          desc: '总数、每页条数、跳页，省略号折叠长页码',
          wide: true,
          child: WePagination(
            total: 1286,
            page: _page,
            pageSize: _pageSize,
            pageSizes: const [10, 20, 50, 100],
            showTotal: true,
            showJumper: true,
            small: true,
            alignment: MainAxisAlignment.start,
            onPageChanged: (p) => setState(() => _page = p),
            onPageSizeChanged: (s) => setState(() {
              _pageSize = s;
              _page = 1;
            }),
          ),
        ),
        const _Demo(
          name: 'WeDescriptions',
          we: 'we-descriptions',
          fit: WePlatformFit.universal,
          desc: '标签 / 值网格，可跨列、带边框、自定义内容',
          child: WeDescriptions(
            columns: 2,
            bordered: true,
            size: SizeEnum.small,
            items: [
              WeDescriptionItem('订单号', 'YJ20260920001'),
              WeDescriptionItem('买家', '林砚秋'),
              WeDescriptionItem(
                '状态',
                '',
                child: Tag(
                  '已发货',
                  type: SemanticEnum.success,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
              ),
              WeDescriptionItem('金额', '¥1,299.00'),
              WeDescriptionItem('收货地址', '广东省深圳市南山区科技园南区 8 栋 12 层', span: 2),
            ],
          ),
        ),
        const _Demo(
          name: 'WeTimeline',
          we: 'we-timeline',
          fit: WePlatformFit.universal,
          desc: '竖向事件流，节点可带图标、语义色、空心',
          child: WeTimeline(
            items: [
              WeTimelineItem(
                title: '下单',
                timestamp: '09:12',
                type: SemanticEnum.primary,
                icon: Icons.shopping_cart_outlined,
              ),
              WeTimelineItem(
                title: '支付成功',
                timestamp: '09:13',
                type: SemanticEnum.success,
              ),
              WeTimelineItem(
                title: '已发货',
                timestamp: '14:40',
                description: '顺丰 SF1234567890',
                hollow: true,
              ),
              WeTimelineItem(title: '待签收', timestamp: '—'),
            ],
          ),
        ),
        _Demo(
          name: 'WeCollapse',
          we: 'we-collapse',
          fit: WePlatformFit.universal,
          desc: '手风琴、右侧 extra、禁用项；Tab 聚焦标题后 Enter / 空格切换',
          child: WeCollapse(
            expanded: _collapse,
            accordion: true,
            onChanged: (s) => setState(() => _collapse = s),
            items: const [
              WeCollapseItem(
                name: 'a',
                title: '基础信息',
                icon: Icons.info_outline,
                child: WeText('名称、类目、主图'),
              ),
              WeCollapseItem(
                name: 'b',
                title: '价格库存',
                icon: Icons.payments_outlined,
                extra: Tag(
                  '2 项待填',
                  type: SemanticEnum.warning,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
                child: WeText('SKU 与首发价'),
              ),
              WeCollapseItem(
                name: 'c',
                title: '已归档',
                disabled: true,
                child: WeText('不可展开'),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeCarousel',
          we: 'we-carousel',
          fit: WePlatformFit.universal,
          desc: '自动播放、指示器、悬停箭头',
          wide: true,
          child: WeCarousel(
            height: 96,
            autoplay: false,
            arrow: WeCarouselArrow.always,
            children: [
              for (final c in [
                SemanticEnum.primary,
                SemanticEnum.success,
                SemanticEnum.warning,
              ])
                ColoredBox(
                  color: context.weColors.light(c, 8),
                  child: Center(child: WeText(c.name)),
                ),
            ],
          ),
        ),
        _Demo(
          name: 'WeTree',
          we: 'we-tree',
          fit: WePlatformFit.universal,
          desc: '父子联动勾选（禁用项不跟着勾）、过滤高亮、键盘 ↑↓←→ Enter 空格',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeInput(
                width: 220,
                size: SizeEnum.small,
                hint: '过滤节点',
                prefixIcon: Icons.search_rounded,
                clearable: true,
                onChanged: (v) => setState(() => _treeQuery = v),
              ),
              const SizedBox(height: 8),
              WeTree<String>(
                nodes: _demoTree,
                defaultExpandAll: true,
                showCheckbox: true,
                filter: _treeQuery,
                selected: _treeSelected,
                checked: _treeChecked,
                onSelect: (v) => setState(() => _treeSelected = v),
                onCheck: (s) => setState(() => _treeChecked = s),
              ),
              const SizedBox(height: 6),
              WeText(
                _treeChecked.isEmpty ? '未勾选' : '已勾选：${_treeChecked.join('、')}',
                role: WeTextRole.secondary,
                size: SizeEnum.small,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeProgress',
          we: 'we-progress',
          fit: WePlatformFit.universal,
          desc: '线形 / 环形 / 仪表盘，状态色、分段色、条纹动画、不定态',
          wide: true,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: WeProgress(percentage: _progress)),
                  const SizedBox(width: 16),
                  WeButtonGroup(
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    children: [
                      WeButton.icon(
                        Icons.remove_rounded,
                        onPressed: () => setState(
                          () => _progress = (_progress - 10).clamp(0, 100),
                        ),
                      ),
                      WeButton.icon(
                        Icons.add_rounded,
                        onPressed: () => setState(
                          () => _progress = (_progress + 10).clamp(0, 100),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              WeProgress(
                percentage: _progress,
                status: SemanticEnum.success,
                textInside: true,
                strokeWidth: 18,
              ),
              const SizedBox(height: 10),
              WeProgress(
                percentage: _progress,
                striped: true,
                colorStops: {
                  60: colors.danger,
                  80: colors.warning,
                  100: colors.success,
                },
              ),
              const SizedBox(height: 10),
              const WeProgress(percentage: 30, indeterminate: true),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WeProgress(
                    percentage: _progress,
                    type: WeProgressType.circle,
                    width: 90,
                  ),
                  WeProgress(
                    percentage: _progress,
                    type: WeProgressType.circle,
                    width: 90,
                    status: SemanticEnum.warning,
                  ),
                  WeProgress(
                    percentage: _progress,
                    type: WeProgressType.dashboard,
                    width: 90,
                    status: SemanticEnum.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 导航 ──────────────────────────────────────────────────────────────

  Widget _navigation() {
    return _Grid(
      children: [
        _Demo(
          name: 'WeMenu',
          we: 'we-menu',
          fit: WePlatformFit.desktop,
          desc: '分组 / 子菜单 / 角标 / 禁用，折叠成图标栏时悬停弹出',
          child: SizedBox(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: WeMenu(
                    selectedId: _menu,
                    onSelect: (id) => setState(() => _menu = id),
                    defaultOpenIds: const {'goods'},
                    entries: const [
                      WeMenuItem(
                        'overview',
                        '经营概览',
                        icon: Icons.space_dashboard_outlined,
                      ),
                      WeMenuGroup(
                        '交易',
                        children: [
                          WeSubMenu(
                            'goods',
                            '商品管理',
                            icon: Icons.inventory_2_outlined,
                            children: [
                              WeMenuItem('products', '商品列表'),
                              WeMenuItem('stock', '库存预警', badge: 12),
                            ],
                          ),
                          WeMenuItem(
                            'orders',
                            '订单管理',
                            icon: Icons.receipt_long_outlined,
                            badge: 128,
                          ),
                        ],
                      ),
                      WeMenuItem(
                        'disabled',
                        '禁用项',
                        icon: Icons.block_rounded,
                        disabled: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 64,
                  child: WeMenu(
                    collapsed: true,
                    selectedId: _menu,
                    onSelect: (id) => setState(() => _menu = id),
                    entries: const [
                      WeMenuItem(
                        'overview',
                        '经营概览',
                        icon: Icons.space_dashboard_outlined,
                      ),
                      WeSubMenu(
                        'goods',
                        '商品管理',
                        icon: Icons.inventory_2_outlined,
                        children: [
                          WeMenuItem('products', '商品列表'),
                          WeMenuItem('stock', '库存预警', badge: 12),
                        ],
                      ),
                      WeMenuItem(
                        'orders',
                        '订单管理',
                        icon: Icons.receipt_long_outlined,
                        badge: 128,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _Demo(
          name: 'WeTabbar',
          we: 'van-tabbar',
          fit: WePlatformFit.mobile,
          desc:
              '手机 App 底部的导航栏，平分宽度；数字角标、小红点、选中换实心图标；再点一次当前项触发 onReselect（常用来回到顶部）',
          child: Container(
            width: 360,
            height: 220,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: context.weColors.baseBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: context.weColors.lightFill,
                    alignment: Alignment.center,
                    child: WeText(
                      '${_tabbarItems[_tabbar].label}页'
                      '${_tabbarReselect == 0 ? '' : '（回到顶部 $_tabbarReselect 次）'}',
                      role: WeTextRole.secondary,
                    ),
                  ),
                ),
                WeTabbar(
                  index: _tabbar,
                  safeArea: false,
                  items: _tabbarItems,
                  onChanged: (i) => setState(() {
                    _tabbar = i;
                    _tabbarReselect = 0;
                  }),
                  onReselect: (_) => setState(() => _tabbarReselect++),
                ),
              ],
            ),
          ),
        ),
        _Demo(
          name: 'WeTabs',
          we: 'we-tabs',
          fit: WePlatformFit.universal,
          desc: 'line / card / borderCard 三种样式，图标、角标、禁用、stretch',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeTabs(
                index: _tab,
                size: SizeEnum.small,
                onChanged: (i) => setState(() => _tab = i),
                tabs: const [
                  WeTab('全部', icon: Icons.list_alt_rounded),
                  WeTab('待发货', badge: 128),
                  WeTab('退款', badge: 23),
                  WeTab('已关闭', disabled: true),
                ],
              ),
              const SizedBox(height: 12),
              WeTabs(
                index: _tab,
                type: WeTabsType.card,
                size: SizeEnum.small,
                onChanged: (i) => setState(() => _tab = i),
                tabs: const [
                  WeTab('全部'),
                  WeTab('待发货'),
                  WeTab('退款'),
                  WeTab('已关闭'),
                ],
              ),
              const SizedBox(height: 12),
              WeTabs(
                index: _tab,
                type: WeTabsType.borderCard,
                size: SizeEnum.small,
                stretch: true,
                onChanged: (i) => setState(() => _tab = i),
                tabs: const [
                  WeTab('全部'),
                  WeTab('待发货'),
                  WeTab('退款'),
                  WeTab('已关闭'),
                ],
                children: [
                  for (final t in const ['全部', '待发货', '退款', '已关闭'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: WeText(
                        '$t 面板内容',
                        role: WeTextRole.secondary,
                        size: SizeEnum.small,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeSegmented',
          we: 'we-segmented',
          fit: WePlatformFit.universal,
          desc: '并排单选，选中项浮起；block 撑满，可带图标与语义色',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeSegmented<String>(
                value: _seg,
                onChanged: (v) => setState(() => _seg = v),
                options: const [
                  WeSegmentedOption('day', '日', icon: Icons.today_rounded),
                  WeSegmentedOption(
                    'week',
                    '周',
                    icon: Icons.date_range_rounded,
                  ),
                  WeSegmentedOption(
                    'month',
                    '月',
                    icon: Icons.calendar_month_rounded,
                  ),
                  WeSegmentedOption('year', '年', disabled: true),
                ],
              ),
              const SizedBox(height: 10),
              WeSegmented<String>(
                value: _seg,
                block: true,
                size: SizeEnum.small,
                type: SemanticEnum.success,
                onChanged: (v) => setState(() => _seg = v),
                options: const [
                  WeSegmentedOption('day', '日'),
                  WeSegmentedOption('week', '周'),
                  WeSegmentedOption('month', '月'),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeBreadcrumb',
          we: 'we-breadcrumb',
          fit: WePlatformFit.universal,
          desc: '文字或图标分隔符，非当前项可点击',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeBreadcrumb(
                items: [
                  WeBreadcrumbItem(
                    '首页',
                    icon: Icons.home_outlined,
                    onTap: () {},
                  ),
                  WeBreadcrumbItem('商品管理', onTap: () {}),
                  const WeBreadcrumbItem('商品列表'),
                ],
              ),
              const SizedBox(height: 10),
              WeBreadcrumb(
                separatorIcon: Icons.chevron_right_rounded,
                items: [
                  WeBreadcrumbItem('首页', onTap: () {}),
                  WeBreadcrumbItem('订单管理', onTap: () {}),
                  const WeBreadcrumbItem('退款售后'),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeDropdown',
          we: 'we-dropdown',
          fit: WePlatformFit.universal,
          desc: '任意子组件作触发器，或用 .builder 自定义按钮；分隔线、禁用、语义色',
          child: Wrap(
            spacing: 14,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WeDropdown<String>(
                items: const [
                  WeDropdownItem('a', '导出 CSV', icon: Icons.table_view_rounded),
                  WeDropdownItem('b', '导出 Excel', icon: Icons.grid_on_rounded),
                  WeDropdownItem(
                    'c',
                    '打印',
                    icon: Icons.print_outlined,
                    disabled: true,
                  ),
                  WeDropdownItem(
                    'd',
                    '删除',
                    icon: Icons.delete_outline_rounded,
                    divided: true,
                    type: SemanticEnum.danger,
                  ),
                ],
                onSelected: (v) => WeMessage.info(context, '选择了 $v'),
                child: const WeLink(
                  '更多操作',
                  trailingIcon: Icons.expand_more_rounded,
                  underline: false,
                ),
              ),
              WeDropdown<String>.builder(
                items: const [
                  WeDropdownItem('1', '近 7 天'),
                  WeDropdownItem('2', '近 30 天'),
                  WeDropdownItem('3', '自定义'),
                ],
                onSelected: (v) => WeMessage.info(context, '范围 $v'),
                builder: (ctx, open) => WeButton(
                  text: '时间范围',
                  trailingIcon: Icons.arrow_drop_down_rounded,
                  variant: WeButtonVariant.plain,
                  size: SizeEnum.small,
                  onPressed: open,
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeSteps',
          we: 'we-steps',
          fit: WePlatformFit.universal,
          desc: '横向 / 居中 / 纵向 / simple，finish、process、error 状态，可点击回跳',
          wide: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeSteps(
                active: _step,
                onTap: (i) => setState(() => _step = i),
                steps: const [
                  WeStep(title: '填写商品信息', description: '名称、类目、主图'),
                  WeStep(title: '设置价格库存', description: 'SKU 与首发价'),
                  WeStep(title: '提交审核', description: '1 个工作日内'),
                  WeStep(title: '上架成功'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  WeButton(
                    text: '上一步',
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: _step > 0 ? () => setState(() => _step--) : null,
                  ),
                  const SizedBox(width: 8),
                  WeButton(
                    text: _step >= 3 ? '完成' : '下一步',
                    size: SizeEnum.small,
                    type: SemanticEnum.primary,
                    onPressed: _step < 4 ? () => setState(() => _step++) : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const WeSteps(
                active: 2,
                simple: true,
                steps: [
                  WeStep(title: '选择商品'),
                  WeStep(title: '确认订单'),
                  WeStep(title: '支付失败', status: WeStepStatus.error),
                  WeStep(title: '完成'),
                ],
              ),
              const SizedBox(height: 20),
              const WeSteps(
                active: 1,
                alignCenter: true,
                steps: [
                  WeStep(title: '已下单', icon: Icons.shopping_bag_outlined),
                  WeStep(title: '运输中', icon: Icons.local_shipping_outlined),
                  WeStep(title: '已签收', icon: Icons.inventory_outlined),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WePageHeader',
          we: 'we-page-header',
          fit: WePlatformFit.universal,
          desc: '页标题、说明、返回、操作区',
          wide: true,
          child: WePageHeader(
            title: '商品详情',
            description: 'SKU-1024 · 家居日用',
            onBack: () => WeMessage.info(context, '返回列表'),
            tag: const Tag(
              '在售',
              type: SemanticEnum.success,
              theme: TagThemeEnum.light,
              size: SizeEnum.small,
            ),
            actions: const [
              WeButton(
                text: '编辑',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 反馈 ──────────────────────────────────────────────────────────────

  Widget _feedback() {
    final colors = context.weColors;
    return _Grid(
      children: [
        _Demo(
          name: 'WeTooltip',
          we: 'we-tooltip',
          fit: WePlatformFit.desktop,
          desc: 'dark / light 两种效果，12 个方向，贴边时自动翻转并平移',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (p, label) in const [
                (WePlacement.top, '上'),
                (WePlacement.bottom, '下'),
                (WePlacement.left, '左'),
                (WePlacement.right, '右'),
                (WePlacement.topStart, '上左'),
                (WePlacement.bottomEnd, '下右'),
              ])
                WeTooltip(
                  content: 'placement: ${p.name}',
                  placement: p,
                  child: WeButton(
                    text: label,
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: () {},
                  ),
                ),
              WeTooltip(
                effect: WeTooltipEffect.light,
                content: '浅色效果，带边框和阴影',
                child: WeButton(
                  text: 'light',
                  size: SizeEnum.small,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WePopover / WePopconfirm',
          we: 'we-popover',
          fit: WePlatformFit.universal,
          desc: '点击弹出的卡片；贴在按钮上的确认气泡，异步确认时按钮转圈',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WePopover.builder(
                title: '今日库存',
                width: 240,
                contentBuilder: (_) => const WeDescriptions(
                  columns: 1,
                  size: SizeEnum.small,
                  items: [
                    WeDescriptionItem('在售', '1,204 件'),
                    WeDescriptionItem('锁定', '86 件'),
                    WeDescriptionItem('在途', '320 件'),
                  ],
                ),
                builder: (_, toggle) => WeButton(
                  text: '点击查看',
                  size: SizeEnum.small,
                  variant: WeButtonVariant.plain,
                  onPressed: toggle,
                ),
              ),
              const WePopover(
                trigger: WePopperTrigger.hover,
                placement: WePlacement.right,
                content: '悬停触发的 Popover，移到卡片上不会消失。',
                width: 200,
                child: WeLink('悬停我', type: SemanticEnum.primary),
              ),
              WePopconfirm.builder(
                title: '确定下架这件商品吗？',
                type: SemanticEnum.danger,
                confirmText: '下架',
                onConfirm: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 800));
                  if (mounted) WeMessage.success(context, '已下架');
                },
                builder: (_, open) => WeButton(
                  text: '下架',
                  size: SizeEnum.small,
                  type: SemanticEnum.danger,
                  variant: WeButtonVariant.plain,
                  onPressed: open,
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WePopper',
          we: 'popper',
          fit: WePlatformFit.universal,
          desc: '以上浮层和下拉的底座：跟随滚动、翻转、Esc 只关最上层；也可以用 controller 从外部控制',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WePopper(
                controller: _popper,
                trigger: WePopperTrigger.manual,
                placement: WePlacement.right,
                showArrow: true,
                popupBuilder: (_) => const Text('由外部按钮控制'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.lightFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const WeText('目标', size: SizeEnum.small),
                ),
              ),
              WeButton(
                text: '显示 / 隐藏',
                size: SizeEnum.small,
                onPressed: _popper.toggle,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeDrawer',
          we: 'we-drawer',
          fit: WePlatformFit.universal,
          desc: '四个方向滑出、可拖边调整尺寸、beforeClose 关闭前确认',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (d, label) in const [
                (WeDrawerDirection.rtl, '右侧'),
                (WeDrawerDirection.ltr, '左侧'),
                (WeDrawerDirection.ttb, '顶部'),
                (WeDrawerDirection.btt, '底部'),
              ])
                WeButton(
                  text: label,
                  size: SizeEnum.small,
                  variant: WeButtonVariant.plain,
                  onPressed: () => WeDrawer.show<void>(
                    context,
                    direction: d,
                    size: d.isHorizontal ? 0.3 : 0.4,
                    resizable: true,
                    title: '$label抽屉',
                    child: const WeText('拖动内侧边缘可以调整尺寸，点遮罩或按 Esc 关闭。'),
                  ),
                ),
              WeButton(
                text: '关闭前确认',
                size: SizeEnum.small,
                type: SemanticEnum.warning,
                onPressed: () => WeDrawer.show<void>(
                  context,
                  title: '编辑草稿',
                  beforeClose: () =>
                      WeMessageBox.confirm(context, '草稿还没保存，确定关闭吗？'),
                  child: const WeText('尝试点遮罩、按 Esc 或点右上角关闭。'),
                  actions: (c) => [
                    WeButton(
                      text: '保存并关闭',
                      type: SemanticEnum.primary,
                      onPressed: () => Navigator.pop(c),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeAlert',
          we: 'we-alert',
          fit: WePlatformFit.universal,
          desc: 'light / dark 两种效果，标题 + 描述，可关闭，可带操作',
          wide: true,
          child: Column(
            children: [
              for (final t in [
                SemanticEnum.success,
                SemanticEnum.warning,
                SemanticEnum.danger,
                SemanticEnum.info,
              ]) ...[
                WeAlert(
                  type: t,
                  title: '${t.name} 提示',
                  description: '这是一条 ${t.name} 类型的说明文字。',
                  closable: true,
                  action: t == SemanticEnum.warning
                      ? WeButton(
                          text: '去处理',
                          type: t,
                          size: SizeEnum.small,
                          onPressed: () {},
                        )
                      : null,
                ),
                const SizedBox(height: 8),
              ],
              const WeAlert(
                type: SemanticEnum.primary,
                effect: WeAlertEffect.dark,
                title: 'dark 效果',
                closable: false,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeMessage',
          we: 'we-message',
          fit: WePlatformFit.universal,
          desc: '顶部居中滑入、自动堆叠、可关闭、plain 模式',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: 'success',
                type: SemanticEnum.success,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () => WeMessage.success(context, '保存成功'),
              ),
              WeButton(
                text: 'warning',
                type: SemanticEnum.warning,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () => WeMessage.warning(context, '库存不足'),
              ),
              WeButton(
                text: 'error',
                type: SemanticEnum.danger,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () =>
                    WeMessage.error(context, '网络异常', closable: true),
              ),
              WeButton(
                text: 'info',
                type: SemanticEnum.info,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () => WeMessage.info(context, '这是一条消息'),
              ),
              WeButton(
                text: 'plain',
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () =>
                    WeMessage.success(context, 'plain 样式', plain: true),
              ),
              const WeButton(
                text: '关闭全部',
                variant: WeButtonVariant.text,
                size: SizeEnum.small,
                onPressed: WeMessage.closeAll,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeLoading',
          we: 'v-loading',
          fit: WePlatformFit.universal,
          desc: '区域遮罩与全屏 Overlay，不占用对话框栈',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeLoading(
                loading: _regionBusy,
                text: '加载中',
                child: Container(
                  height: 72,
                  alignment: Alignment.center,
                  child: const WeText('这是一块表格区域'),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  WeButton(
                    text: _regionBusy ? '停' : '区域加载',
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: () => setState(() => _regionBusy = !_regionBusy),
                  ),
                  WeButton(
                    text: '全屏 1 秒',
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    onPressed: () async {
                      final h = WeLoading.service(context, text: '请稍候');
                      await Future<void>.delayed(const Duration(seconds: 1));
                      h.close();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeNotification',
          we: 'we-notification',
          fit: WePlatformFit.universal,
          desc: '四角堆叠通知，返回句柄可提前关掉；短提示用 WeMessage',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: '右上',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeNotification.success(
                  context,
                  title: '导出完成',
                  message: '文件已保存到下载目录',
                ),
              ),
              WeButton(
                text: '左下',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeNotification.show(
                  context,
                  position: WeNotificationPosition.bottomLeft,
                  title: '库存告急',
                  message: '仅剩 46 件',
                  type: SemanticEnum.warning,
                ),
              ),
              WeButton(
                text: '居中提示',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeMessage.info(context, '居中提示'),
              ),
              WeButton(
                text: '底部提示',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeMessage.success(context, '已复制'),
              ),
              const WeButton(
                text: '关闭全部',
                variant: WeButtonVariant.text,
                size: SizeEnum.small,
                onPressed: WeNotification.closeAll,
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeDialog',
          we: 'we-dialog',
          fit: WePlatformFit.universal,
          desc: '拖住标题栏可以把弹窗挪到任意位置（双击标题栏复位）；支持顶部对齐、全屏、自定义页脚、Esc 关闭',
          wide: true,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: '基础弹窗',
                type: SemanticEnum.primary,
                size: SizeEnum.small,
                onPressed: () => WeDialog.show<void>(
                  context,
                  title: '发布商品',
                  icon: Icons.add_business_rounded,
                  child: const WeText(
                    '弹窗内容可以是任意 Widget，超长时自动出现滚动条。试着拖动标题栏把它挪到一边。',
                  ),
                  actions: (ctx) => [
                    WeButton(
                      text: '取消',
                      variant: WeButtonVariant.plain,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    WeButton(
                      text: '确定',
                      type: SemanticEnum.primary,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              WeButton(
                text: '顶部对齐',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeDialog.show<void>(
                  context,
                  title: '顶部对齐（top: 80）',
                  top: 80,
                  child: const WeText('和 we-dialog 的 top 一样，距顶固定距离，适合长表单。'),
                  actions: (ctx) => [
                    WeButton(
                      text: '知道了',
                      type: SemanticEnum.primary,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              WeButton(
                text: '不可拖动',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeDialog.show<void>(
                  context,
                  title: '固定位置',
                  draggable: false,
                  child: const WeText('draggable: false 就退回普通的居中模态。'),
                  actions: (ctx) => [
                    WeButton(
                      text: '关闭',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              WeButton(
                text: '全屏',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeDialog.show<void>(
                  context,
                  title: '全屏弹窗',
                  fullscreen: true,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WeText('fullscreen: true 会铺满整个视口。'),
                      SizedBox(height: 12),
                      WeSkeleton(rows: 6),
                    ],
                  ),
                  actions: (ctx) => [
                    WeButton(
                      text: '退出全屏',
                      type: SemanticEnum.primary,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              WeButton(
                text: '长内容滚动',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeDialog.show<void>(
                  context,
                  title: '服务协议',
                  width: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 1; i <= 12; i++) ...[
                        WeText(
                          '第 $i 条　商家应保证所售商品来源合法、标识齐全，并对商品描述的真实性负责。',
                          size: SizeEnum.small,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                  actions: (ctx) => [
                    WeButton(
                      text: '不同意',
                      variant: WeButtonVariant.plain,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    WeButton(
                      text: '同意并继续',
                      type: SemanticEnum.primary,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeMessageBox',
          we: 'we-message-box',
          fit: WePlatformFit.universal,
          desc: 'alert / confirm / prompt 三件套，返回 Future，可拖动',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: 'alert',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WeMessageBox.alert(
                  context,
                  '本次导出包含手机号，请遵守隐私规范。',
                  title: '导出提醒',
                ),
              ),
              WeButton(
                text: 'confirm',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                type: SemanticEnum.danger,
                onPressed: () async {
                  final bool ok = await WeMessageBox.confirm(
                    context,
                    '删除后不可恢复，历史订单仍保留快照。确认删除？',
                    title: '删除商品',
                    confirmText: '确认删除',
                    type: SemanticEnum.danger,
                  );
                  if (!mounted) return;
                  ok
                      ? WeMessage.success(context, '已删除')
                      : WeMessage.info(context, '已取消');
                },
              ),
              WeButton(
                text: 'prompt',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () async {
                  final String? name = await WeMessageBox.prompt(
                    context,
                    '给这批优惠券起个名字：',
                    title: '新建券包',
                    hint: '2-12 个字',
                    validator: (v) {
                      if (v.trim().isEmpty) return '名称不能为空';
                      if (v.trim().length < 2) return '至少 2 个字';
                      return null;
                    },
                  );
                  if (!mounted || name == null) return;
                  WeMessage.success(context, '已创建「$name」');
                },
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WinStyleDialog',
          we: '—（桌面风格）',
          fit: WePlatformFit.desktop,
          desc: '标题栏 + 正文 + 命令栏的桌面式弹窗，标题栏同样可拖动，关闭按钮悬停变红',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: '桌面风格弹窗',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WinDialogs.show<void>(
                  context,
                  title: '导出订单.csv',
                  icon: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF409EFF),
                  ),
                  text: '将当前筛选结果导出为 CSV，最多 10000 行。导出任务完成后会通过站内信通知。',
                  actions: (ctx) => [
                    WeButton(
                      text: '取消',
                      variant: WeButtonVariant.plain,
                      size: SizeEnum.small,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    WeButton(
                      text: '开始导出',
                      type: SemanticEnum.primary,
                      size: SizeEnum.small,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              WeButton(
                text: 'zoomIn 动画',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => WinDialogs.zoomIn<void>(
                  context,
                  title: '磁盘空间不足',
                  icon: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE6A23C),
                  ),
                  text: '素材库剩余空间不足 2GB，建议清理历史活动图片。',
                  actions: (ctx) => [
                    WeButton(
                      text: '稍后',
                      variant: WeButtonVariant.plain,
                      size: SizeEnum.small,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    WeButton(
                      text: '去清理',
                      type: SemanticEnum.warning,
                      size: SizeEnum.small,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'BottomSheets',
          we: 'bottom sheet',
          fit: WePlatformFit.mobile,
          desc: '移动端的底部弹层；桌面端的信息 / 确认弹窗请用上面的 WeMessageBox',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WeButton(
                text: 'Info Sheet',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                onPressed: () => BottomSheets.showInfoSheet(
                  context,
                  noImage: true,
                  title: '底部弹层',
                  message: '从底部滑出的信息层。',
                  buttonText: '好的',
                  type: SemanticEnum.primary,
                  onTapDismiss: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
        _Demo(
          name: 'WeEmpty',
          we: 'we-empty',
          fit: WePlatformFit.universal,
          desc: '无数据占位：图标 / 自定义图、描述、操作',
          child: WeEmpty(
            description: '还没有任何订单',
            padding: const EdgeInsets.symmetric(vertical: 16),
            action: WeButton(
              text: '去铺货',
              type: SemanticEnum.primary,
              size: SizeEnum.small,
              onPressed: () {},
            ),
          ),
        ),
        _Demo(
          name: 'WeResult',
          we: 'we-result',
          fit: WePlatformFit.universal,
          desc: '操作结果页：大图标 + 标题 + 副标题 + 操作区',
          child: WeResult(
            type: SemanticEnum.success,
            title: '提交成功',
            subtitle: '活动将在风控复核后自动开始投放',
            padding: const EdgeInsets.symmetric(vertical: 12),
            actions: [
              WeButton(
                text: '返回',
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () {},
              ),
              WeButton(
                text: '查看活动',
                type: SemanticEnum.primary,
                size: SizeEnum.small,
                onPressed: () {},
              ),
            ],
          ),
        ),
        const _Demo(
          name: 'WeSkeleton',
          we: 'we-skeleton',
          fit: WePlatformFit.universal,
          desc: '段落、单块、头像行三种骨架，带流光动画',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeSkeleton(rows: 3),
              SizedBox(height: 14),
              WeSkeleton.avatarRow(),
              SizedBox(height: 14),
              Row(
                children: [
                  WeSkeleton.block(width: 80, height: 80, radius: 8),
                  SizedBox(width: 12),
                  Expanded(child: WeSkeleton.block(height: 16)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 页面内小件 ──────────────────────────────────────────────────────────

class _Sku {
  const _Sku(this.id, this.name, this.price, this.rating);

  final String id;
  final String name;
  final double price;
  final double rating;
}

/// 把页面顶部的「平台筛选」和「按手机预览」传给每个分类的网格。
class _GalleryScope extends InheritedWidget {
  const _GalleryScope({
    required this.filter,
    required this.phone,
    required super.child,
  });

  /// 为 null 时显示全部。
  final WePlatformFit? filter;
  final bool phone;

  static _GalleryScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GalleryScope>();

  @override
  bool updateShouldNotify(_GalleryScope old) =>
      old.filter != filter || old.phone != phone;
}

/// 手机预览的屏幕尺寸，取常见的 390 × 844。
const Size _kPhoneSize = Size(390, 844);

/// 两列 / 一列自适应的卡片网格；`wide` 的卡片独占一行。
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<_Demo> children;

  @override
  Widget build(BuildContext context) {
    final _GalleryScope? scope = _GalleryScope.of(context);
    final WePlatformFit? filter = scope?.filter;
    final List<_Demo> shown = [
      for (final d in children)
        if (filter == null || d.fit == filter) d,
    ];
    if (shown.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: WeEmpty(description: '这个分类里没有该平台的组件，换个分类或选「全部」看看'),
      );
    }

    final Widget grid = Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, box) {
          final bool twoUp = box.maxWidth > 980;
          final double half = (box.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final d in shown)
                SizedBox(
                  width: twoUp && !d.wide ? half : box.maxWidth,
                  child: d,
                ),
            ],
          );
        },
      ),
    );
    if (scope == null || !scope.phone) return grid;
    return _PhoneFrame(child: grid);
  }
}

/// 把内容放进 390 宽的「手机」里：平台换成 Android，组件因此按触屏显示（尺寸变大、悬停改点按）。
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final colors = context.weColors;
    return Center(
      child: Container(
        key: const ValueKey('phone-frame'),
        width: _kPhoneSize.width + 16,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.pageBackground,
          border: Border.all(color: colors.darkerBorder, width: 2),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(size: _kPhoneSize),
            child: Theme(
              data: theme.copyWith(platform: TargetPlatform.android),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Demo extends StatelessWidget {
  const _Demo({
    required this.name,
    required this.we,
    required this.fit,
    required this.desc,
    required this.child,
    this.wide = false,
  });

  final String name;
  final String we;

  /// 适用平台，卡片右上角用图标标签标出。
  final WePlatformFit fit;
  final String desc;
  final Widget child;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return WeCard(
      title: name,
      subtitle: desc,
      shadow: WeCardShadow.hover,
      // 窄屏上标题旁放不下两个标签，只留平台标签。
      extra: MediaQuery.sizeOf(context).width < 600
          ? _FitTag(fit)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FitTag(fit),
                const SizedBox(width: 6),
                Tag(
                  we,
                  size: SizeEnum.small,
                  theme: TagThemeEnum.plain,
                  type: SemanticEnum.info,
                ),
              ],
            ),
      child: child,
    );
  }
}

/// 平台标签：通用用灰色，网页 / 桌面用蓝色，手机用绿色。
class _FitTag extends StatelessWidget {
  const _FitTag(this.fit);

  final WePlatformFit fit;

  static SemanticEnum typeOf(WePlatformFit fit) => switch (fit) {
    WePlatformFit.universal => SemanticEnum.secondary,
    WePlatformFit.desktop => SemanticEnum.primary,
    WePlatformFit.mobile => SemanticEnum.success,
  };

  @override
  Widget build(BuildContext context) {
    final Color c = context.weColors.semantic(typeOf(fit));
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        border: Border.all(color: c.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fit.icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(fit.label, style: TextStyle(fontSize: 12, color: c)),
        ],
      ),
    );
  }
}
