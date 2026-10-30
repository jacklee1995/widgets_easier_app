import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// 侧边栏的导航树，直接喂给 [WeMenu]。叶子的 id 决定右侧渲染哪个页面。
const List<WeMenuEntry> kNav = [
  WeMenuItem('overview', '经营概览', icon: Icons.space_dashboard_outlined),
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
          WeMenuItem('category', '分类与属性'),
        ],
      ),
      WeSubMenu(
        'trade',
        '订单管理',
        icon: Icons.receipt_long_outlined,
        badge: 128,
        children: [
          WeMenuItem('orders', '全部订单'),
          WeMenuItem('orders-packing', '待发货', badge: 128),
          WeMenuItem('orders-refund', '退款售后', badge: 23),
        ],
      ),
      WeMenuItem('logistics', '物流配送', icon: Icons.local_shipping_outlined),
    ],
  ),
  WeMenuGroup(
    '增长',
    children: [
      WeSubMenu(
        'growth',
        '营销中心',
        icon: Icons.local_offer_outlined,
        children: [
          WeMenuItem('coupons', '优惠券'),
          WeMenuItem('seckill', '限时秒杀'),
          WeMenuItem('groupon', '拼团裂变'),
        ],
      ),
      WeMenuItem('members', '会员运营', icon: Icons.groups_outlined),
      WeSubMenu(
        'report',
        '数据报表',
        icon: Icons.insights_outlined,
        children: [
          WeMenuItem('report-sales', '销售看板'),
          WeMenuItem('report-rank', '品类排行'),
          WeMenuItem('report-channel', '渠道分析'),
        ],
      ),
      WeMenuItem('review', '内容与评价', icon: Icons.reviews_outlined),
    ],
  ),
  WeMenuGroup(
    '系统',
    children: [
      WeMenuItem(
        'finance',
        '财务结算',
        icon: Icons.account_balance_wallet_outlined,
      ),
      WeMenuItem('settings', '系统设置', icon: Icons.settings_outlined),
      WeMenuItem('components', '组件总览', icon: Icons.widgets_outlined),
      WeMenuItem('docs', '组件文档', icon: Icons.menu_book_outlined),
    ],
  ),
];

/// 从根到 [id] 的标签串；分组只是标题，不算层级。找不到时为空。
List<String> _pathTo(String id, [List<WeMenuEntry> entries = kNav]) {
  for (final e in entries) {
    switch (e) {
      case WeMenuItem():
        if (e.id == id) return [e.label];
      case WeMenuGroup():
        final below = _pathTo(id, e.children);
        if (below.isNotEmpty) return below;
      case WeSubMenu():
        final below = _pathTo(id, e.children);
        if (below.isNotEmpty) return [e.label, ...below];
    }
  }
  return const [];
}

/// 从节点 id 还原顶部面包屑。
List<String> breadcrumbOf(String id) => ['首页', ..._pathTo(id)];

/// 节点 id 对应的页面标题与副标题。
({String title, String description}) metaOf(String id) => switch (id) {
  'overview' => (title: '经营概览', description: '今天的成交、履约与流量都在这里，异常会先在上方告警条提示。'),
  'products' => (title: '商品列表', description: '维护 SKU 的价格、库存与上下架状态，改动即时同步到各渠道。'),
  'stock' => (title: '库存预警', description: '低于安全库存的 SKU 会被挑出来，支持直接在列表里补货。'),
  'orders' => (title: '全部订单', description: '滚动加载最近的交易流水，点行可以查看履约详情。'),
  'orders-packing' => (title: '待发货', description: '已付款未出库的订单，超过 12 小时会标红提醒。'),
  'orders-refund' => (
    title: '退款售后',
    description: '仅退款与退货退款的工单，需要客服在 24 小时内响应。',
  ),
  'coupons' => (title: '营销中心', description: '优惠券、秒杀与拼团的投放配置，实时看核销率。'),
  'members' => (title: '会员运营', description: '会员分层、成长值与流失预警，支持定向发券。'),
  'settings' => (title: '系统设置', description: '店铺信息、通知策略与安全设置。'),
  'components' => (
    title: '组件总览',
    description: '对照 Element Plus 的组件清单，每个 We 组件一张卡，附最小用法。',
  ),
  'docs' => (title: '组件文档', description: '这套后台用到的 Widgets Easier 组件，逐个看用法。'),
  _ => (
    title: metaTitleFallback(id),
    description: '这个模块还在排期中，下面是已确认的功能清单与上线节奏。',
  ),
};

String metaTitleFallback(String id) {
  final path = _pathTo(id);
  return path.isEmpty ? '未命名' : path.last;
}
