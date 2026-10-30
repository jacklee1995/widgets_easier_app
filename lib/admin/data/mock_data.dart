import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// 静态假数据。真实后台在这里换成接口层即可，页面不用改。

// ── 商品 ────────────────────────────────────────────────────────────────

enum ProductStatus { onSale, lowStock, soldOut, draft }

extension ProductStatusLabel on ProductStatus {
  String get label => switch (this) {
    ProductStatus.onSale => '在售',
    ProductStatus.lowStock => '库存紧张',
    ProductStatus.soldOut => '已售罄',
    ProductStatus.draft => '未上架',
  };

  SemanticEnum get semantic => switch (this) {
    ProductStatus.onSale => SemanticEnum.success,
    ProductStatus.lowStock => SemanticEnum.warning,
    ProductStatus.soldOut => SemanticEnum.danger,
    ProductStatus.draft => SemanticEnum.secondary,
  };
}

@immutable
class Product {
  const Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.sold,
    required this.rating,
    required this.status,
    required this.emoji,
    required this.tint,
  });

  final String sku;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int sold;
  final double rating;
  final ProductStatus status;

  /// 缩略图占位用的表情与底色，避免示例依赖外网图片。
  final String emoji;
  final Color tint;

  Product copyWith({int? stock, double? price}) => Product(
    sku: sku,
    name: name,
    category: category,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    sold: sold,
    rating: rating,
    status: status,
    emoji: emoji,
    tint: tint,
  );
}

const List<Product> kProducts = [
  Product(
    sku: 'SKU-100281',
    name: '云锦真丝眼罩 · 助眠款',
    category: '家居日用',
    price: 129,
    stock: 862,
    sold: 12480,
    rating: 4.9,
    status: ProductStatus.onSale,
    emoji: '🛏️',
    tint: Color(0xFF7C6BFF),
  ),
  Product(
    sku: 'SKU-100344',
    name: '轻氧胶囊咖啡机 Mini',
    category: '厨房电器',
    price: 899,
    stock: 46,
    sold: 3271,
    rating: 4.7,
    status: ProductStatus.lowStock,
    emoji: '☕',
    tint: Color(0xFFFF8A4C),
  ),
  Product(
    sku: 'SKU-100519',
    name: '无界降噪耳机 Air Pro',
    category: '数码配件',
    price: 1299,
    stock: 0,
    sold: 8964,
    rating: 4.8,
    status: ProductStatus.soldOut,
    emoji: '🎧',
    tint: Color(0xFF3FB6FF),
  ),
  Product(
    sku: 'SKU-100722',
    name: '山野冻干果茶 12 条装',
    category: '食品生鲜',
    price: 69,
    stock: 4210,
    sold: 26315,
    rating: 4.6,
    status: ProductStatus.onSale,
    emoji: '🍑',
    tint: Color(0xFFFF6B8B),
  ),
  Product(
    sku: 'SKU-100896',
    name: '折叠通勤伞 · 十骨加固',
    category: '出行户外',
    price: 89,
    stock: 128,
    sold: 5402,
    rating: 4.5,
    status: ProductStatus.onSale,
    emoji: '☂️',
    tint: Color(0xFF34C6A8),
  ),
  Product(
    sku: 'SKU-101034',
    name: '静音人体工学椅 E3',
    category: '家具家装',
    price: 1680,
    stock: 23,
    sold: 1187,
    rating: 4.4,
    status: ProductStatus.lowStock,
    emoji: '🪑',
    tint: Color(0xFF9B8CFF),
  ),
  Product(
    sku: 'SKU-101158',
    name: '限定联名帆布包（预热）',
    category: '服饰箱包',
    price: 199,
    stock: 600,
    sold: 0,
    rating: 0,
    status: ProductStatus.draft,
    emoji: '👜',
    tint: Color(0xFF8E97A6),
  ),
  Product(
    sku: 'SKU-101263',
    name: '白桃乌龙香薰蜡烛',
    category: '家居日用',
    price: 158,
    stock: 731,
    sold: 9043,
    rating: 4.8,
    status: ProductStatus.onSale,
    emoji: '🕯️',
    tint: Color(0xFFFFB03A),
  ),
];

// ── 订单 ────────────────────────────────────────────────────────────────

enum OrderStatus { pending, packing, shipped, done, refunding }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => '待付款',
    OrderStatus.packing => '待发货',
    OrderStatus.shipped => '运输中',
    OrderStatus.done => '已完成',
    OrderStatus.refunding => '退款中',
  };

  SemanticEnum get semantic => switch (this) {
    OrderStatus.pending => SemanticEnum.warning,
    OrderStatus.packing => SemanticEnum.primary,
    OrderStatus.shipped => SemanticEnum.info,
    OrderStatus.done => SemanticEnum.success,
    OrderStatus.refunding => SemanticEnum.danger,
  };

  IconData get icon => switch (this) {
    OrderStatus.pending => Icons.hourglass_bottom_rounded,
    OrderStatus.packing => Icons.inventory_2_outlined,
    OrderStatus.shipped => Icons.local_shipping_outlined,
    OrderStatus.done => Icons.task_alt_rounded,
    OrderStatus.refunding => Icons.assignment_return_outlined,
  };
}

@immutable
class Order {
  const Order({
    required this.no,
    required this.buyer,
    required this.product,
    required this.quantity,
    required this.amount,
    required this.channel,
    required this.province,
    required this.placedAt,
    required this.status,
  });

  final String no;
  final String buyer;
  final String product;
  final int quantity;
  final double amount;
  final String channel;
  final String province;
  final String placedAt;
  final OrderStatus status;
}

const List<String> _buyers = [
  '陈一诺',
  '林叙白',
  '周知秋',
  '许听海',
  '沈云舟',
  '苏南枝',
  '顾青野',
  '温言之',
  '方与时',
  '柳见山',
  '黎今朝',
  '江晚舟',
];

const List<String> _channels = ['小程序商城', 'App 商城', '抖音小店', '线下门店', '企业采购'];

const List<String> _provinces = [
  '广东 · 深圳',
  '浙江 · 杭州',
  '江苏 · 南京',
  '四川 · 成都',
  '北京 · 朝阳',
  '湖北 · 武汉',
  '福建 · 厦门',
];

/// 按页造订单，给 PaginationView 当数据源。
List<Order> buildOrders(int page, int pageSize) {
  final rnd = math.Random(page * 7919);
  return List.generate(pageSize, (i) {
    final seq = (page - 1) * pageSize + i;
    final product = kProducts[rnd.nextInt(kProducts.length)];
    final quantity = 1 + rnd.nextInt(4);
    return Order(
      no: 'EC2026${(430182 - seq * 37).toString().padLeft(6, '0')}',
      buyer: _buyers[rnd.nextInt(_buyers.length)],
      product: product.name,
      quantity: quantity,
      amount: product.price * quantity,
      channel: _channels[rnd.nextInt(_channels.length)],
      province: _provinces[rnd.nextInt(_provinces.length)],
      placedAt:
          '09-20 '
          '${(9 + rnd.nextInt(13)).toString().padLeft(2, '0')}:'
          '${rnd.nextInt(60).toString().padLeft(2, '0')}',
      status: OrderStatus.values[rnd.nextInt(OrderStatus.values.length)],
    );
  });
}

// ── 会员 ────────────────────────────────────────────────────────────────

@immutable
class Member {
  const Member({
    required this.name,
    required this.level,
    required this.orders,
    required this.spend,
    required this.growth,
    required this.lastSeen,
    required this.risk,
  });

  final String name;
  final String level;
  final int orders;
  final double spend;

  /// 成长值进度，0～1。
  final double growth;
  final String lastSeen;
  final bool risk;
}

const List<Member> kMembers = [
  Member(
    name: '陈一诺',
    level: '黑钻会员',
    orders: 148,
    spend: 92460,
    growth: 0.93,
    lastSeen: '2 小时前',
    risk: false,
  ),
  Member(
    name: '林叙白',
    level: '白金会员',
    orders: 96,
    spend: 51280,
    growth: 0.71,
    lastSeen: '今天 10:24',
    risk: false,
  ),
  Member(
    name: '周知秋',
    level: '黄金会员',
    orders: 63,
    spend: 28710,
    growth: 0.54,
    lastSeen: '昨天',
    risk: false,
  ),
  Member(
    name: '许听海',
    level: '白银会员',
    orders: 27,
    spend: 9860,
    growth: 0.32,
    lastSeen: '17 天前',
    risk: true,
  ),
  Member(
    name: '沈云舟',
    level: '普通会员',
    orders: 8,
    spend: 1420,
    growth: 0.12,
    lastSeen: '43 天前',
    risk: true,
  ),
];

// ── 优惠券 ──────────────────────────────────────────────────────────────

@immutable
class Coupon {
  const Coupon({
    required this.name,
    required this.rule,
    required this.face,
    required this.issued,
    required this.used,
    required this.deadline,
    required this.type,
  });

  final String name;
  final String rule;

  /// 面额，展示用。
  final String face;
  final int issued;
  final int used;
  final String deadline;
  final SemanticEnum type;

  double get usage => issued == 0 ? 0 : used / issued;
}

const List<Coupon> kCoupons = [
  Coupon(
    name: '新客首单礼',
    rule: '满 99 元可用',
    face: '¥30',
    issued: 42000,
    used: 31860,
    deadline: '2026-10-07',
    type: SemanticEnum.danger,
  ),
  Coupon(
    name: '会员日通用券',
    rule: '满 299 元可用',
    face: '¥60',
    issued: 18000,
    used: 7920,
    deadline: '2026-09-28',
    type: SemanticEnum.warning,
  ),
  Coupon(
    name: '家居专区折扣',
    rule: '全品类 8.5 折',
    face: '8.5折',
    issued: 9600,
    used: 8352,
    deadline: '2026-09-24',
    type: SemanticEnum.success,
  ),
  Coupon(
    name: '包邮补贴券',
    rule: '不限金额',
    face: '免邮',
    issued: 26000,
    used: 11180,
    deadline: '2026-12-31',
    type: SemanticEnum.primary,
  ),
];

// ── 图表数据 ────────────────────────────────────────────────────────────

/// 近 14 天成交额（万元）。
const List<double> kGmvTrend = [
  38.2,
  41.6,
  36.9,
  44.3,
  52.1,
  61.7,
  58.4,
  47.2,
  49.8,
  55.6,
  63.9,
  71.4,
  68.2,
  74.9,
];

/// 同期支付订单数（千单）。
const List<double> kOrderTrend = [
  12.4,
  13.1,
  11.8,
  14.6,
  16.9,
  19.2,
  18.1,
  15.3,
  16.0,
  17.7,
  20.4,
  22.8,
  21.6,
  23.5,
];

/// 渠道成交占比。
const List<({String name, double value, Color color})> kChannelShare = [
  (name: '小程序商城', value: 38, color: Color(0xFF6C7BFF)),
  (name: 'App 商城', value: 26, color: Color(0xFF3FC8B0)),
  (name: '抖音小店', value: 18, color: Color(0xFFFF8A4C)),
  (name: '线下门店', value: 11, color: Color(0xFFFFC53D)),
  (name: '企业采购', value: 7, color: Color(0xFFB09BFF)),
];

/// 各品类销售额（万元），横向条形图用。
const List<({String name, double value})> kCategorySales = [
  (name: '家居日用', value: 186.4),
  (name: '数码配件', value: 152.7),
  (name: '食品生鲜', value: 138.2),
  (name: '厨房电器', value: 97.5),
  (name: '服饰箱包', value: 64.1),
  (name: '出行户外', value: 41.8),
];

/// 首页待办。
const List<({String title, String desc, SemanticEnum type, IconData icon})>
kTodos = [
  (
    title: '待发货订单',
    desc: '128 笔订单已超过 12 小时未出库',
    type: SemanticEnum.warning,
    icon: Icons.inventory_2_outlined,
  ),
  (
    title: '退款待审核',
    desc: '23 笔仅退款申请等待客服确认',
    type: SemanticEnum.danger,
    icon: Icons.assignment_return_outlined,
  ),
  (
    title: '商品待审核',
    desc: '9 个新品文案与主图待合规检查',
    type: SemanticEnum.primary,
    icon: Icons.fact_check_outlined,
  ),
  (
    title: '评价待回复',
    desc: '41 条中差评超过 24 小时未响应',
    type: SemanticEnum.info,
    icon: Icons.reviews_outlined,
  ),
];
