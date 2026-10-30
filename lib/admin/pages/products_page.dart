import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_data.dart';
import '../data/mock_upload.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 商品类目树：叶子的值就是 [Product.category]，父节点只用来分组。
/// 筛选区和新品表单共用这一棵。
const _kCategoryTree = [
  WeTreeNode(
    'home-root',
    '家居生活',
    children: [
      WeTreeNode('家居日用', '家居日用'),
      WeTreeNode('家具家装', '家具家装'),
      WeTreeNode('厨房电器', '厨房电器'),
    ],
  ),
  WeTreeNode(
    'digital-root',
    '数码出行',
    children: [WeTreeNode('数码配件', '数码配件'), WeTreeNode('出行户外', '出行户外')],
  ),
  WeTreeNode(
    'life-root',
    '食衣',
    children: [WeTreeNode('食品生鲜', '食品生鲜'), WeTreeNode('服饰箱包', '服饰箱包')],
  ),
];

/// 商品列表：筛选 + WeTable + 行内改库存 + 批量操作 + 分页。
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, this.onlyLowStock = false});

  /// 「库存预警」入口复用同一个页面，只是默认筛掉了正常库存的 SKU。
  final bool onlyLowStock;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final List<Product> _products = List.of(kProducts);
  final Map<String, CounterInputController> _stockControllers = {};

  Set<Product> _selected = {};
  Set<String> _categories = {};
  String _keyword = '';
  RangeValues _price = const RangeValues(0, 2000);
  ProductStatus? _status;
  String _sort = 'sold';
  int _page = 1;
  int _pageSize = 10;
  bool _striped = true;
  bool _bordered = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.onlyLowStock) _status = ProductStatus.lowStock;
  }

  @override
  void dispose() {
    for (final c in _stockControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  CounterInputController _stockOf(Product p) => _stockControllers.putIfAbsent(
    p.sku,
    () => CounterInputController(initialValue: p.stock.toDouble()),
  );

  List<Product> get _visible {
    final list = _products.where((p) {
      if (_keyword.isNotEmpty &&
          !p.name.contains(_keyword) &&
          !p.sku.toLowerCase().contains(_keyword.toLowerCase())) {
        return false;
      }
      if (_categories.isNotEmpty && !_categories.contains(p.category)) {
        return false;
      }
      if (_status != null && p.status != _status) return false;
      return p.price >= _price.start && p.price <= _price.end;
    }).toList();
    switch (_sort) {
      case 'price':
        list.sort((a, b) => b.price.compareTo(a.price));
      case 'stock':
        list.sort((a, b) => a.stock.compareTo(b.stock));
      default:
        list.sort((a, b) => b.sold.compareTo(a.sold));
    }
    return list;
  }

  void _reset() => setState(() {
    _keyword = '';
    _categories = {};
    _status = widget.onlyLowStock ? ProductStatus.lowStock : null;
    _price = const RangeValues(0, 2000);
    _page = 1;
  });

  Future<void> _reload() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    WeMessage.success(context, '商品数据已刷新');
  }

  void _setStock(Product product, double value) {
    setState(() {
      final i = _products.indexWhere((p) => p.sku == product.sku);
      if (i != -1) _products[i] = _products[i].copyWith(stock: value.round());
    });
  }

  Future<void> _delete(Product product) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _products.removeWhere((p) => p.sku == product.sku);
      _selected.remove(product);
    });
    WeMessage.success(context, '${product.sku} 已从商品库移除');
  }

  void _showDetail(Product product) {
    WeDialog.show<void>(
      context,
      title: product.name,
      width: 520,
      titleWidget: Row(
        children: [
          ProductThumb(emoji: product.emoji, tint: product.tint, size: 28),
          const SizedBox(width: 10),
          Flexible(
            child: WeText(
              product.name,
              size: SizeEnum.large,
              bold: true,
              truncate: true,
            ),
          ),
          const SizedBox(width: 8),
          Tag(product.sku, theme: TagThemeEnum.light, size: SizeEnum.small),
        ],
      ),
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          WeAlert(
            title: '${product.category} · 上架 ${product.sold} 件',
            description: '拖动标题栏可以把弹窗挪开，方便对照后面的列表。',
            type: SemanticEnum.info,
            closable: false,
          ),
          const SizedBox(height: 14),
          _ProductGallery(product: product),
          const SizedBox(height: 14),
          WeDescriptions(
            columns: 2,
            bordered: true,
            size: SizeEnum.small,
            labelWidth: 84,
            items: [
              WeDescriptionItem('售价', '¥${product.price.toStringAsFixed(2)}'),
              WeDescriptionItem(
                '状态',
                '',
                child: Tag(
                  product.status.label,
                  type: product.status.semantic,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
              ),
              WeDescriptionItem('库存', '${product.stock} 件'),
              WeDescriptionItem('累计销量', '${product.sold} 件'),
              WeDescriptionItem(
                '评分',
                '',
                span: 2,
                child: product.rating == 0
                    ? const WeText(
                        '暂无评分',
                        role: WeTextRole.placeholder,
                        size: SizeEnum.small,
                      )
                    : WeRate(
                        value: product.rating,
                        readOnly: true,
                        showScore: true,
                        size: 16,
                      ),
              ),
            ],
          ),
        ],
      ),
      actions: (context) => [
        WeButton(
          text: '关闭',
          variant: WeButtonVariant.plain,
          onPressed: () => Navigator.of(context).pop(),
        ),
        WeButton(
          text: '编辑商品',
          type: SemanticEnum.primary,
          icon: Icons.edit_outlined,
          onPressed: () {
            Navigator.of(context).pop();
            WeMessage.info(context, '打开编辑器…');
          },
        ),
      ],
    );
  }

  Future<void> _publish() async {
    final String? name = await WeDialog.show<String>(
      context,
      title: '发布新品',
      icon: Icons.add_business_rounded,
      width: 560,
      builder: (context) => const _PublishForm(),
    );
    if (name == null || !mounted) return;

    WeNotification.show(
      context,
      title: '已提交',
      message: '「$name」已进入审核队列，预计 2 小时内出结果。',
      type: SemanticEnum.success,
    );
  }

  void _batchSheet() {
    BottomSheets.showConfirmSheet(
      context,
      noImage: true,
      title: '批量上架',
      message: '已选中 ${_selected.length} 个 SKU，将同时在小程序、App 与抖音小店上架。',
      confirmButtonText: '立即上架',
      cancelButtonText: '取消',
      type: SemanticEnum.success,
      onTapConfirm: () {
        Navigator.of(context).pop();
        WeMessage.success(context, '${_selected.length} 个 SKU 已上架');
        setState(() => _selected = {});
      },
      onTapCancel: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    final list = _visible;
    final int start = (_page - 1) * _pageSize;
    final paged = list.skip(start).take(_pageSize).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WePageHeader(
            title: widget.onlyLowStock ? '库存预警' : '商品列表',
            description: widget.onlyLowStock
                ? '低于安全库存的 SKU，支持直接在列表里补货'
                : '共 ${_products.length} 个 SKU，当前筛选出 ${list.length} 个',
            tag: widget.onlyLowStock
                ? WeBadge(value: list.length, type: SemanticEnum.warning)
                : null,
            actions: [
              WeDropdown<String>.builder(
                alignRight: true,
                width: 180,
                onSelected: (v) => WeMessage.info(context, '开始$v'),
                items: const [
                  WeDropdownItem(
                    '导入 Excel',
                    '导入 Excel',
                    icon: Icons.table_view_outlined,
                  ),
                  WeDropdownItem(
                    '导入 1688 商品',
                    '从 1688 导入',
                    icon: Icons.cloud_download_outlined,
                  ),
                  WeDropdownItem(
                    '导出全部',
                    '导出全部商品',
                    icon: Icons.download_outlined,
                    divided: true,
                  ),
                ],
                builder: (_, open) => WeButton(
                  text: '导入 / 导出',
                  trailingIcon: Icons.expand_more_rounded,
                  variant: WeButtonVariant.plain,
                  size: SizeEnum.small,
                  onPressed: open,
                ),
              ),
              WeButton(
                text: '发布新品',
                icon: Icons.add_rounded,
                type: SemanticEnum.primary,
                size: SizeEnum.small,
                onPressed: _publish,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 筛选区 ────────────────────────────────────────────────
          Panel(
            title: '筛选条件',
            subtitle: '条件之间是「与」的关系',
            icon: Icons.filter_alt_outlined,
            trailing: WeButton(
              text: '重置',
              icon: Icons.restart_alt_rounded,
              variant: WeButtonVariant.text,
              size: SizeEnum.small,
              onPressed: _reset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SearchField(
                      hint: '商品名称或 SKU',
                      width: 220,
                      onChanged: (v) => setState(() {
                        _keyword = v;
                        _page = 1;
                      }),
                    ),
                    WeTreeSelect<String>.multiple(
                      width: 260,
                      hint: '全部类目',
                      prefixIcon: Icons.category_outlined,
                      nodes: _kCategoryTree,
                      filterable: true,
                      clearable: true,
                      collapseTags: true,
                      values: _categories,
                      onValuesChanged: (v) => setState(() {
                        _categories = v;
                        _page = 1;
                      }),
                    ),
                    WeSelect<ProductStatus?>(
                      width: 150,
                      hint: '全部状态',
                      clearable: true,
                      prefixIcon: Icons.flag_outlined,
                      value: _status,
                      options: [
                        for (final s in ProductStatus.values)
                          WeSelectOption(s, s.label),
                      ],
                      onChanged: (v) => setState(() {
                        _status = v;
                        _page = 1;
                      }),
                    ),
                    WeSelect<String>(
                      width: 150,
                      prefixIcon: Icons.sort_rounded,
                      value: _sort,
                      options: const [
                        WeSelectOption('sold', '按销量'),
                        WeSelectOption('price', '按售价'),
                        WeSelectOption('stock', '按库存'),
                      ],
                      onChanged: (v) => setState(() => _sort = v ?? 'sold'),
                    ),
                    const SizedBox(height: 20, child: WeDivider.vertical()),
                    const WeText(
                      '表格',
                      role: WeTextRole.secondary,
                      size: SizeEnum.small,
                    ),
                    WeSwitch(
                      value: _striped,
                      size: SizeEnum.small,
                      activeText: '斑马纹',
                      onChanged: (v) => setState(() => _striped = v),
                    ),
                    WeSwitch(
                      value: _bordered,
                      size: SizeEnum.small,
                      activeText: '边框',
                      onChanged: (v) => setState(() => _bordered = v),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const WeText(
                      '价格区间',
                      role: WeTextRole.secondary,
                      size: SizeEnum.small,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RangeSlider(
                        values: _price,
                        min: 0,
                        max: 2000,
                        divisions: 40,
                        activeColor: colors.primary,
                        inactiveColor: colors.lightFill,
                        labels: RangeLabels(
                          '¥${_price.start.round()}',
                          '¥${_price.end.round()}',
                        ),
                        onChanged: (v) => setState(() {
                          _price = v;
                          _page = 1;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tag(
                      '¥${_price.start.round()} - ¥${_price.end.round()}',
                      type: SemanticEnum.primary,
                      theme: TagThemeEnum.plain,
                      size: SizeEnum.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 批量操作条 ────────────────────────────────────────────
          if (_selected.isNotEmpty) ...[
            AlertBanner(
              type: SemanticEnum.primary,
              title: '已选择 ${_selected.length} 项',
              message: '可以批量上架、调价或加入活动。',
              onClose: () => setState(() => _selected = {}),
              action: WeButtonGroup(
                size: SizeEnum.small,
                children: [
                  WeButton(
                    text: '批量上架',
                    type: SemanticEnum.primary,
                    onPressed: _batchSheet,
                  ),
                  WeButton(
                    text: '批量调价',
                    type: SemanticEnum.primary,
                    onPressed: () => WeMessage.info(context, '打开批量调价面板…'),
                  ),
                  WeButton(
                    text: '加入活动',
                    type: SemanticEnum.primary,
                    onPressed: () => WeMessage.info(context, '选择要加入的活动…'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── 列表 ──────────────────────────────────────────────────
          Panel(
            title: '商品',
            subtitle: '库存可以直接在行内加减，改动会立刻同步到各渠道；表头可排序',
            icon: Icons.inventory_2_outlined,
            trailing: WeButton.icon(
              Icons.refresh_rounded,
              variant: WeButtonVariant.text,
              size: SizeEnum.small,
              tooltip: '刷新',
              loading: _loading,
              onPressed: _reload,
            ),
            padding: EdgeInsets.zero,
            child: WeTable<Product>(
              rows: paged,
              loading: _loading,
              striped: _striped,
              bordered: _bordered,
              selectable: true,
              selected: _selected,
              onSelectionChanged: (s) => setState(() => _selected = s),
              onRowTap: _showDetail,
              rowHeight: 64,
              empty: EmptyState(
                title: '没有符合条件的商品',
                description: '放宽价格区间或清掉类目筛选再试',
                action: WeButton(
                  text: '清空筛选',
                  type: SemanticEnum.primary,
                  size: SizeEnum.small,
                  onPressed: _reset,
                ),
              ),
              columns: [
                WeColumn(
                  title: '商品',
                  flex: 3,
                  sortBy: (p) => p.name,
                  cell: (_, p) => Row(
                    children: [
                      ProductThumb(emoji: p.emoji, tint: p.tint, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WeText(
                              p.name,
                              role: WeTextRole.primary,
                              bold: true,
                              truncate: true,
                            ),
                            const SizedBox(height: 3),
                            WeText(
                              '${p.sku} · ${p.category}',
                              role: WeTextRole.placeholder,
                              size: SizeEnum.small,
                              truncate: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                WeColumn(
                  title: '售价',
                  width: 110,
                  sortBy: (p) => p.price,
                  cell: (_, p) => WeStatistic(
                    title: '',
                    value: p.price,
                    prefix: '¥',
                    precision: 0,
                    valueSize: 15,
                    compact: true,
                  ),
                ),
                WeColumn(
                  title: '评分',
                  width: 150,
                  sortBy: (p) => p.rating,
                  cell: (_, p) => p.rating == 0
                      ? const WeText(
                          '暂无',
                          role: WeTextRole.placeholder,
                          size: SizeEnum.small,
                        )
                      : WeRate(
                          value: p.rating,
                          readOnly: true,
                          size: 14,
                          showScore: true,
                        ),
                ),
                WeColumn(
                  title: '状态',
                  width: 110,
                  sortBy: (p) => p.status.index,
                  cell: (_, p) => WeTooltip(
                    content: switch (p.status) {
                      ProductStatus.lowStock => '库存 ${p.stock} 件，低于安全库存，建议尽快补货',
                      ProductStatus.soldOut => '已售罄，补货后自动恢复在售',
                      _ => '${p.status.label} · 库存 ${p.stock} 件',
                    },
                    child: Tag(
                      p.status.label,
                      type: p.status.semantic,
                      theme: TagThemeEnum.light,
                      size: SizeEnum.small,
                    ),
                  ),
                ),
                WeColumn(
                  title: '库存',
                  width: 190,
                  sortBy: (p) => p.stock,
                  cell: (ctx, p) => CounterInput(
                    controller: _stockOf(p),
                    size: SizeEnum.small,
                    minValue: 0,
                    maxValue: 99999,
                    step: 10,
                    textFieldWidth: 54,
                    type: SemanticEnum.secondary,
                    onValueChanged: (_, next) => _setStock(p, next),
                    onMin: () => WeMessage.warning(ctx, '库存已清零，商品会自动置为售罄'),
                  ),
                ),
                WeColumn(
                  title: '操作',
                  width: 140,
                  align: Alignment.centerRight,
                  cell: (ctx, p) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WeButton.icon(
                        Icons.visibility_outlined,
                        variant: WeButtonVariant.text,
                        size: SizeEnum.small,
                        tooltip: '查看详情',
                        onPressed: () => _showDetail(p),
                      ),
                      WeButton.icon(
                        Icons.edit_outlined,
                        variant: WeButtonVariant.text,
                        size: SizeEnum.small,
                        tooltip: '编辑',
                        onPressed: () => WeMessage.info(ctx, '打开编辑器…'),
                      ),
                      WePopconfirm.builder(
                        title: '删除「${p.name}」？历史订单会保留快照。',
                        width: 220,
                        placement: WePlacement.topEnd,
                        type: SemanticEnum.danger,
                        confirmText: '删除',
                        onConfirm: () => _delete(p),
                        builder: (_, open) => WeButton.icon(
                          Icons.delete_outline_rounded,
                          variant: WeButtonVariant.text,
                          type: SemanticEnum.danger,
                          size: SizeEnum.small,
                          tooltip: '删除',
                          onPressed: open,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              footer: WePagination(
                total: list.length,
                page: _page,
                pageSize: _pageSize,
                pageSizes: const [5, 10, 20],
                showTotal: true,
                showJumper: true,
                small: true,
                totalBuilder: (n) => '共 $n 条',
                onPageChanged: (p) => setState(() => _page = p),
                onPageSizeChanged: (s) => setState(() {
                  _pageSize = s;
                  _page = 1;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 弹窗里的新品表单，pop 回商品名表示提交成功。
class _PublishForm extends StatefulWidget {
  const _PublishForm();

  @override
  State<_PublishForm> createState() => _PublishFormState();
}

class _PublishFormState extends State<_PublishForm> {
  static const _initialChannels = {'小程序', 'App'};
  static const _tagOptions = [
    WeSelectOption('新品', '新品'),
    WeSelectOption('热卖', '热卖'),
    WeSelectOption('包邮', '包邮'),
    WeSelectOption('限时折扣', '限时折扣'),
    WeSelectOption('节日礼盒', '节日礼盒'),
    WeSelectOption('低糖', '低糖'),
  ];

  final WeFormController _form = WeFormController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController(text: '99.00');
  final WeUploadController _images = WeUploadController();

  String? _category;
  Set<String> _tags = {};
  Set<String> _channels = {..._initialChannels};
  bool _online = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _images.dispose();
    super.dispose();
  }

  // 模拟服务端查重：商品库里已有同名商品就不让提交。
  Future<String?> _checkName(Object? value) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final String name = '$value'.trim();
    return kProducts.any((p) => p.name == name) ? '商品库里已有「$name」' : null;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final bool ok = await _form.validate();
    if (!mounted) return;
    if (!ok) {
      setState(() => _submitting = false);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pop(_name.text.trim());
  }

  void _resetAll() {
    _form.resetFields();
    WeMessage.info(context, '已恢复为初始内容');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WeAlert(
          title: '草稿会自动保存',
          description: '关掉弹窗也不会丢，回到「商品列表 - 未上架」继续编辑。',
          type: SemanticEnum.info,
          closable: false,
        ),
        const SizedBox(height: 16),
        WeForm(
          controller: _form,
          labelWidth: 96,
          children: [
            WeFormItem(
              name: 'name',
              label: '商品名称',
              valueGetter: () => _name.text,
              rules: [
                const WeRule(required: true),
                const WeRule(min: 4, max: 30, trigger: WeRuleTrigger.blur),
                WeRule(validator: _checkName, trigger: WeRuleTrigger.blur),
              ],
              onReset: _name.clear,
              child: WeInput(
                controller: _name,
                hint: '例如：低糖桂花麻薯 6 枚装',
                maxLength: 30,
                showWordLimit: true,
                autofocus: true,
              ),
            ),
            WeFormItem(
              name: 'images',
              label: '商品主图',
              valueGetter: () => _images.files,
              rules: [
                const WeRule(required: true, message: '至少上传一张主图'),
                WeRule(
                  validator: (_) =>
                      _images.files.any(
                        (f) => f.status == WeUploadStatus.uploading,
                      )
                      ? '图片还在上传，请稍候'
                      : _images.files.any(
                          (f) => f.status == WeUploadStatus.fail,
                        )
                      ? '有图片上传失败，请重试或删除'
                      : null,
                ),
              ],
              onReset: _images.clear,
              child: WeUpload(
                controller: _images,
                picker: mockUpload.pickImages,
                uploader: mockUpload.upload,
                multiple: true,
                limit: 5,
                accept: const ['image/*'],
                maxSize: 2 * 1024 * 1024,
                listType: WeUploadListType.pictureCard,
                cardSize: 88,
                tip: '每次从素材库取 2 张，最多 5 张；每第 4 次上传会模拟断网，悬停卡片可重试',
              ),
            ),
            WeFormItem(
              name: 'category',
              label: '所属类目',
              value: _category,
              rules: const [WeRule(required: true, message: '请选择类目')],
              onReset: () => setState(() => _category = null),
              child: WeTreeSelect<String>(
                nodes: _kCategoryTree,
                value: _category,
                hint: '选择类目',
                filterable: true,
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            WeFormItem(
              name: 'tags',
              label: '营销标签',
              value: _tags,
              onReset: () => setState(() => _tags = {}),
              child: WeSelect<String>.multiple(
                values: _tags,
                hint: '可选，最多 3 个',
                clearable: true,
                multipleLimit: 3,
                options: _tagOptions,
                onChanged: (v) => setState(() => _tags = v),
              ),
            ),
            WeFormItem(
              name: 'price',
              label: '首发售价',
              valueGetter: () => _price.text,
              rules: [
                const WeRule(required: true),
                WeRule(
                  pattern: RegExp(r'^\d+(\.\d{1,2})?$'),
                  message: '请输入金额，最多两位小数',
                ),
                WeRule(
                  validator: (v) =>
                      (double.tryParse('$v') ?? 0) <= 0 ? '售价要大于 0' : null,
                ),
              ],
              onReset: () => _price.text = '99.00',
              child: WeInput(
                controller: _price,
                prepend: const Text('¥'),
                append: const Text('元 / 件'),
                keyboardType: TextInputType.number,
              ),
            ),
            WeFormItem(
              name: 'channels',
              label: '上架渠道',
              value: _channels,
              rules: const [WeRule(required: true, message: '至少选择一个渠道')],
              onReset: () => setState(() => _channels = {..._initialChannels}),
              child: WeCheckboxGroup<String>(
                value: _channels,
                options: const {
                  '小程序': '小程序',
                  'App': 'App',
                  '抖音小店': '抖音小店',
                  '线下门店': '线下门店',
                },
                onChanged: (v) => setState(() => _channels = v),
              ),
            ),
            WeFormItem(
              label: '审核通过后',
              onReset: () => setState(() => _online = true),
              child: Align(
                alignment: Alignment.centerLeft,
                child: WeSwitch(
                  value: _online,
                  activeText: '自动上架',
                  inactiveText: '手动上架',
                  inlinePrompt: true,
                  onChanged: (v) => setState(() => _online = v),
                ),
              ),
            ),
          ],
        ),
        const WeDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            WeButton(
              text: '重置',
              variant: WeButtonVariant.text,
              onPressed: _submitting ? null : _resetAll,
            ),
            const SizedBox(width: 10),
            WeButton(
              text: '存为草稿',
              variant: WeButtonVariant.plain,
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            WeButton(
              text: '提交审核',
              type: SemanticEnum.primary,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }
}

/// 详情弹窗里的主图：三张缩略图，点任意一张从它开始翻看。
class _ProductGallery extends StatefulWidget {
  const _ProductGallery({required this.product});

  final Product product;

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  late final Future<List<Uint8List>> _images = renderProductGallery(
    widget.product,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
      future: _images,
      builder: (context, snap) {
        final images = snap.data;
        final gallery = [
          for (final b in images ?? const <Uint8List>[]) WeImageSource.bytes(b),
        ];
        return Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              images == null
                  ? const WeSkeleton.block(width: 72, height: 72)
                  : WeImage(
                      bytes: images[i],
                      width: 72,
                      height: 72,
                      radius: BorderRadius.circular(6),
                      preview: true,
                      previewList: gallery,
                      initialIndex: i,
                    ),
            ],
            const SizedBox(width: 12),
            const Expanded(
              child: WeText(
                '点图片放大，可左右翻看、缩放和旋转',
                role: WeTextRole.placeholder,
                size: SizeEnum.small,
              ),
            ),
          ],
        );
      },
    );
  }
}
