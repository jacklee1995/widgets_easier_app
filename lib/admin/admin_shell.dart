import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../theme_mode.dart';
import 'data/mock_data.dart';
import 'nav.dart';
import 'pages/components_page.dart';
import 'pages/marketing_page.dart';
import 'pages/members_page.dart';
import 'pages/orders_page.dart';
import 'pages/overview_page.dart';
import 'pages/products_page.dart';
import 'pages/roadmap_page.dart';
import 'pages/settings_page.dart';
import 'pages/widget_docs_page.dart';
import 'widgets/toolbar.dart';

const double _kSidebarWide = 240;
const double _kSidebarNarrow = 56;
const double _kBreakpoint = 1080;

/// 「云集」电商后台的外壳：左侧导航 + 顶栏 + 内容区。
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _current = 'overview';
  bool _collapsed = false;

  void _select(String id) {
    setState(() => _current = id);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Widget _page() => switch (_current) {
    'overview' || 'report-sales' => OverviewPage(key: ValueKey(_current)),
    'products' => const ProductsPage(key: ValueKey('products')),
    'stock' => const ProductsPage(key: ValueKey('stock'), onlyLowStock: true),
    'orders' => const OrdersPage(key: ValueKey('orders')),
    'orders-packing' => const OrdersPage(
      key: ValueKey('orders-packing'),
      focus: OrderStatus.packing,
    ),
    'orders-refund' => const OrdersPage(
      key: ValueKey('orders-refund'),
      focus: OrderStatus.refunding,
    ),
    'coupons' => const MarketingPage(key: ValueKey('coupons')),
    'members' => const MembersPage(key: ValueKey('members')),
    'settings' => const SettingsPage(key: ValueKey('settings')),
    'docs' => const WidgetDocsPage(key: ValueKey('docs')),
    'components' => const ComponentsPage(key: ValueKey('components')),
    _ => RoadmapPage(key: ValueKey(_current), nodeId: _current),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= _kBreakpoint;
        final sidebar = _Sidebar(
          current: _current,
          collapsed: wide && _collapsed,
          onSelect: _select,
          onToggleCollapse: () => setState(() => _collapsed = !_collapsed),
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.pageBackground,
          drawer: wide ? null : Drawer(width: _kSidebarWide, child: sidebar),
          floatingActionButton: _QuickActionOrb(onSelect: _select),
          body: Row(
            children: [
              if (wide) sidebar,
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      current: _current,
                      showMenu: !wide,
                      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: Container(
                        color: colors.pageBackground,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          // 默认的 layoutBuilder 会把子项居中，内容不满一屏的
                          // 页面就会悬在中间；这里让每一页都撑满内容区。
                          layoutBuilder: (current, previous) => Stack(
                            fit: StackFit.expand,
                            children: [...previous, ?current],
                          ),
                          child: _page(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 侧边栏 ──────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.current,
    required this.collapsed,
    required this.onSelect,
    required this.onToggleCollapse,
  });

  final String current;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: collapsed ? _kSidebarNarrow : _kSidebarWide,
      decoration: BoxDecoration(
        color: colors.baseBackground,
        border: Border(right: BorderSide(color: colors.lighterBorder)),
      ),
      child: Column(
        children: [
          _Brand(collapsed: collapsed),
          Expanded(
            child: WeMenu(
              entries: kNav,
              selectedId: current,
              collapsed: collapsed,
              defaultOpenIds: const {'goods', 'trade'},
              badgeMax: 999,
              onSelect: onSelect,
            ),
          ),
          _CollapseHandle(collapsed: collapsed, onTap: onToggleCollapse),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lighterBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => _row(
          colors,
          // 宽度动画途中先只画 logo，避免文字挤出去。
          collapsed: collapsed || constraints.maxWidth < 160,
        ),
      ),
    );
  }

  Widget _row(WeColorScheme colors, {required bool collapsed}) {
    return Padding(
      // 左边距与菜单图标列的 14 对齐。
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 17,
              color: Colors.white,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '云集商城',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: colors.primaryText,
                    ),
                  ),
                  Text(
                    '商家运营后台',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.3,
                      color: colors.placeholderText,
                    ),
                  ),
                ],
              ),
            ),
            const Tag(
              'v2.6',
              type: SemanticEnum.success,
              theme: TagThemeEnum.light,
              size: SizeEnum.small,
              radius: 2,
            ),
          ],
        ],
      ),
    );
  }
}

/// 底部的收起 / 展开把手。
class _CollapseHandle extends StatelessWidget {
  const _CollapseHandle({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.lighterBorder)),
      ),
      child: Tooltip(
        message: collapsed ? '展开导航' : '收起导航',
        child: InkWell(
          onTap: onTap,
          hoverColor: colors.lightFill,
          child: SizedBox(
            height: 36,
            // 宽度动画途中先只画图标，避免文字挤出去。
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    collapsed
                        ? Icons.keyboard_double_arrow_right
                        : Icons.keyboard_double_arrow_left,
                    size: 16,
                    color: colors.placeholderText,
                  ),
                  if (!collapsed && constraints.maxWidth >= 120) ...[
                    const SizedBox(width: 6),
                    Text(
                      '收起导航',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.placeholderText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 顶栏 ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.current,
    required this.showMenu,
    required this.onMenu,
  });

  final String current;
  final bool showMenu;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final crumbs = breadcrumbOf(current);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.baseBackground,
        border: Border(bottom: BorderSide(color: colors.lighterBorder)),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu_rounded),
              iconSize: 20,
              color: colors.regularText,
            ),
          WeBreadcrumb(
            separatorIcon: Icons.chevron_right_rounded,
            items: [
              for (int i = 0; i < crumbs.length; i++)
                WeBreadcrumbItem(
                  crumbs[i],
                  icon: i == 0 ? Icons.home_outlined : null,
                  onTap: i == crumbs.length - 1
                      ? null
                      : () => WeMessage.info(context, '面包屑：${crumbs[i]}'),
                ),
            ],
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width > 900) ...[
            const SearchField(
              hint: '搜索订单号 / 商品 / 会员',
              width: 230,
              size: SizeEnum.small,
            ),
            const SizedBox(width: 10),
            const Tag(
              '数据同步正常 · 12:02',
              type: SemanticEnum.success,
              theme: TagThemeEnum.light,
              size: SizeEnum.small,
              radius: 999,
            ),
            const SizedBox(width: 10),
          ],
          WeBadge(
            value: 9,
            offset: const Offset(-6, 6),
            child: WeButton.icon(
              Icons.notifications_none_rounded,
              variant: WeButtonVariant.text,
              tooltip: '消息中心',
              onPressed: () => WeNotification.show(
                context,
                title: '履约提醒',
                message: '华东仓 3 笔订单超时未出库，已自动升级为加急。',
                type: SemanticEnum.warning,
              ),
            ),
          ),
          const _ThemeToggle(),
          const SizedBox(width: 6),
          const _UserChip(),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => WeButton.icon(
        switch (mode) {
          ThemeMode.system => Icons.brightness_auto_outlined,
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
        },
        variant: WeButtonVariant.text,
        tooltip: switch (mode) {
          ThemeMode.system => '跟随系统',
          ThemeMode.light => '浅色',
          ThemeMode.dark => '深色',
        },
        onPressed: () => themeMode.value = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        },
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final bool wide = MediaQuery.sizeOf(context).width > 760;
    return WeDropdown<String>(
      alignRight: true,
      width: 180,
      items: const [
        WeDropdownItem('profile', '个人资料', icon: Icons.person_outline_rounded),
        WeDropdownItem('switch', '切换店铺', icon: Icons.storefront_outlined),
        WeDropdownItem('logs', '操作日志', icon: Icons.history_rounded),
        WeDropdownItem(
          'logout',
          '退出登录',
          icon: Icons.logout_rounded,
          divided: true,
          type: SemanticEnum.danger,
        ),
      ],
      onSelected: (v) => v == 'logout'
          ? WeMessage.warning(context, '已退出登录（演示）')
          : WeMessage.info(context, '已打开「$v」'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            WeAvatar(
              text: 'J',
              size: 28,
              color: colors.primary.withValues(alpha: 0.14),
              foregroundColor: colors.primary,
            ),
            const SizedBox(width: 7),
            if (wide)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  WeText(
                    'Jack Li',
                    role: WeTextRole.primary,
                    bold: true,
                    size: SizeEnum.small,
                  ),
                  WeText(
                    '运营负责人',
                    role: WeTextRole.placeholder,
                    size: SizeEnum.small,
                  ),
                ],
              ),
            Icon(
              Icons.expand_more_rounded,
              size: 17,
              color: colors.placeholderText,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 右下角快捷球 ────────────────────────────────────────────────────────

class _QuickActionOrb extends StatelessWidget {
  const _QuickActionOrb({required this.onSelect});

  final ValueChanged<String> onSelect;

  void _open(BuildContext context) {
    final colors = WeTheme.of(context).colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.baseBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.baseBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const WeText(
              '快捷操作',
              role: WeTextRole.primary,
              bold: true,
              size: SizeEnum.large,
            ),
            const SizedBox(height: 4),
            const WeText(
              '常用入口一键直达',
              role: WeTextRole.secondary,
              size: SizeEnum.small,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in const [
                  (
                    label: '发布商品',
                    target: 'products',
                    icon: Icons.add_box_outlined,
                    type: SemanticEnum.primary,
                  ),
                  (
                    label: '批量发货',
                    target: 'orders-packing',
                    icon: Icons.local_shipping_outlined,
                    type: SemanticEnum.success,
                  ),
                  (
                    label: '新建优惠券',
                    target: 'coupons',
                    icon: Icons.confirmation_number_outlined,
                    type: SemanticEnum.warning,
                  ),
                  (
                    label: '会员分层',
                    target: 'members',
                    icon: Icons.workspace_premium_outlined,
                    type: SemanticEnum.info,
                  ),
                  (
                    label: '导出报表',
                    target: 'report-sales',
                    icon: Icons.download_outlined,
                    type: SemanticEnum.secondary,
                  ),
                ])
                  WeButton(
                    text: item.label,
                    icon: item.icon,
                    type: item.type,
                    variant: WeButtonVariant.plain,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      onSelect(item.target);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.fatal, 0.55)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.38),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
