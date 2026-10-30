import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../data/mock_data.dart';
import '../widgets/toolbar.dart';

/// 订单管理：PaginationView 滚动加载 + WeTabs 状态筛选 + WeTable 渲染
/// + WeDescriptions / WeTimeline 的订单详情。
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, this.focus});

  /// 从侧边栏「待发货」「退款售后」进来时预置的状态筛选。
  final OrderStatus? focus;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const int _totalPages = 6;

  late final PaginationLoadingController<Order> _controller =
      PaginationLoadingController<Order>(
        pageSize: 8,
        onLoad: (page, pageSize) async {
          await Future<void>.delayed(const Duration(milliseconds: 550));
          return PaginatedResponse<Order>(
            hasNext: page < _totalPages,
            hasPrevious: page > 1,
            totalPages: _totalPages,
            currentPage: page,
            results: buildOrders(page, pageSize),
          );
        },
      );

  late OrderStatus? _status = widget.focus;
  Set<Order> _selected = {};
  String _keyword = '';

  /// 切状态时模拟一次后端重查：表格保留旧数据，上面盖 WeLoading 遮罩。
  bool _requerying = false;
  int _requeryId = 0;

  Future<void> _switchStatus(OrderStatus? status) async {
    final int id = ++_requeryId;
    setState(() {
      _status = status;
      _requerying = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted || id != _requeryId) return;
    setState(() => _requerying = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _batchShip() {
    BottomSheets.showConfirmSheet(
      context,
      noImage: true,
      title: '批量发货',
      message: _selected.isEmpty
          ? '将为当前筛选出的订单生成电子面单，并推送给合作快递。'
          : '将为选中的 ${_selected.length} 笔订单生成电子面单，并推送给合作快递。',
      confirmButtonText: '生成面单',
      cancelButtonText: '取消',
      type: SemanticEnum.primary,
      onTapConfirm: () {
        Navigator.of(context).pop();
        WeNotification.show(
          context,
          title: '面单生成中',
          message: '预计 1 分钟内完成，可在「物流配送」查看进度。',
          type: SemanticEnum.primary,
        );
        setState(() => _selected = {});
      },
      onTapCancel: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = switch (widget.focus) {
      OrderStatus.packing => (title: '待发货', desc: '已付款未出库的订单，超过 12 小时会标红提醒'),
      OrderStatus.refunding => (title: '退款售后', desc: '仅退款与退货退款的工单，需在 24 小时内响应'),
      _ => (title: '全部订单', desc: '向下滚动自动加载，共 $_totalPages 页交易流水'),
    };

    final statuses = <OrderStatus?>[null, ...OrderStatus.values];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WePageHeader(
                title: meta.title,
                description: meta.desc,
                actions: [
                  WeButton(
                    text: _selected.isEmpty
                        ? '批量发货'
                        : '发货 ${_selected.length} 笔',
                    icon: Icons.local_shipping_outlined,
                    variant: WeButtonVariant.plain,
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    onPressed: _batchShip,
                  ),
                  WeButton(
                    text: '导出订单',
                    icon: Icons.download_outlined,
                    type: SemanticEnum.primary,
                    size: SizeEnum.small,
                    onPressed: () => WeMessage.success(context, '导出任务已提交'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_selected.isNotEmpty) ...[
                AlertBanner(
                  type: SemanticEnum.primary,
                  title: '已选择 ${_selected.length} 笔订单',
                  message:
                      '合计 ¥${_selected.fold<double>(0, (a, o) => a + o.amount).toStringAsFixed(2)}',
                  onClose: () => setState(() => _selected = {}),
                  action: WeButtonGroup(
                    size: SizeEnum.small,
                    variant: WeButtonVariant.plain,
                    type: SemanticEnum.primary,
                    children: [
                      WeButton(text: '打印面单', onPressed: _batchShip),
                      WeButton(
                        text: '备注',
                        onPressed: () => WeMessage.info(context, '打开备注面板…'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: WeCard(
              padding: EdgeInsets.zero,
              fillHeight: true,
              headerPadding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              dividedHeader: false,
              header: Row(
                children: [
                  Expanded(
                    child: WeTabs(
                      index: statuses.indexOf(_status),
                      onChanged: (i) => _switchStatus(statuses[i]),
                      tabs: [
                        const WeTab('全部'),
                        for (final s in OrderStatus.values)
                          WeTab(
                            s.label,
                            icon: s.icon,
                            badge: s == OrderStatus.packing
                                ? 128
                                : s == OrderStatus.refunding
                                ? 23
                                : null,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SearchField(
                    hint: '订单号 / 收货人',
                    width: 210,
                    size: SizeEnum.small,
                    onChanged: (v) => setState(() => _keyword = v),
                  ),
                ],
              ),
              child: PaginationView<Order>(
                controller: _controller,
                delegate: _OrderDelegate(
                  filter: _status,
                  keyword: _keyword,
                  requerying: _requerying,
                  selected: _selected,
                  onSelectionChanged: (s) => setState(() => _selected = s),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 委托决定了分页视图长什么样：刷新、列表容器、单行、加载中、空态。
class _OrderDelegate extends PaginationViewDelegate<Order> {
  _OrderDelegate({
    required this.filter,
    required this.keyword,
    required this.requerying,
    required this.selected,
    required this.onSelectionChanged,
  });

  final OrderStatus? filter;
  final String keyword;
  final bool requerying;
  final Set<Order> selected;
  final ValueChanged<Set<Order>> onSelectionChanged;

  bool _keep(Order o) =>
      (filter == null || o.status == filter) &&
      (keyword.isEmpty || o.no.contains(keyword) || o.buyer.contains(keyword));

  @override
  Widget refreshableView(
    BuildContext context,
    PaginationLoadingController<Order> controller,
    Widget child,
  ) => RefreshIndicator(onRefresh: controller.onRefresh, child: child);

  @override
  Widget childrenLayoutView(
    BuildContext context,
    PaginationLoadingController<Order> controller,
    List<Order> children,
    IndexedWidgetBuilder itemBuilder,
  ) {
    final colors = WeTheme.of(context).colors;
    final visible = children.where(_keep).toList();

    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              final m = n.metrics;
              if (m.pixels >= m.maxScrollExtent - 120) {
                controller.loadNextPage();
              }
              return false;
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WeTable<Order>(
                    rows: visible,
                    loading: requerying,
                    loadingText: '正在筛选订单',
                    hover: true,
                    selectable: true,
                    selected: selected,
                    onSelectionChanged: onSelectionChanged,
                    onRowTap: (o) => _openDetail(context, o),
                    rowHeight: 60,
                    rowColor: (o) => o.status == OrderStatus.refunding
                        ? colors
                              .light(SemanticEnum.danger, 9)
                              .withValues(alpha: 0.5)
                        : null,
                    empty: const EmptyState(
                      title: '这个状态下暂时没有订单',
                      description: '切换到「全部」看看其它状态的流水',
                      icon: Icons.receipt_long_outlined,
                    ),
                    columns: [
                      WeColumn(
                        title: '订单号 / 下单时间',
                        flex: 3,
                        sortBy: (o) => o.no,
                        cell: (ctx, o) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WeLink(
                              o.no,
                              type: SemanticEnum.primary,
                              onTap: () => _openDetail(ctx, o),
                            ),
                            const SizedBox(height: 3),
                            WeText(
                              o.placedAt,
                              role: WeTextRole.placeholder,
                              size: SizeEnum.small,
                            ),
                          ],
                        ),
                      ),
                      WeColumn.text(
                        '商品',
                        (o) => '${o.product} × ${o.quantity}',
                        flex: 3,
                      ),
                      WeColumn(
                        title: '买家 / 收货地',
                        flex: 2,
                        cell: (_, o) => Row(
                          children: [
                            WeAvatar(text: o.buyer.substring(0, 1), size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WeText(
                                    o.buyer,
                                    role: WeTextRole.primary,
                                    truncate: true,
                                  ),
                                  WeText(
                                    o.province,
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
                        title: '渠道',
                        width: 120,
                        cell: (_, o) => Tag(
                          o.channel,
                          size: SizeEnum.small,
                          theme: TagThemeEnum.plain,
                        ),
                      ),
                      WeColumn(
                        title: '金额',
                        width: 120,
                        align: Alignment.centerRight,
                        sortBy: (o) => o.amount,
                        cell: (_, o) => WeStatistic(
                          title: '',
                          value: o.amount,
                          prefix: '¥',
                          valueSize: 14,
                          compact: true,
                        ),
                      ),
                      WeColumn(
                        title: '状态',
                        width: 110,
                        align: Alignment.centerRight,
                        sortBy: (o) => o.status.index,
                        cell: (_, o) => Tag(
                          o.status.label,
                          type: o.status.semantic,
                          theme: TagThemeEnum.light,
                          size: SizeEnum.small,
                        ),
                      ),
                    ],
                  ),
                  _LoadMoreFooter(controller: controller),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.lightFill.withValues(alpha: 0.6),
            border: Border(top: BorderSide(color: colors.lighterBorder)),
          ),
          child: Row(
            children: [
              WeText(
                '已加载 ${children.length} 条 · 第 '
                '${controller.currentPage - 1}/${controller.totalPages} 页',
                role: WeTextRole.secondary,
                size: SizeEnum.small,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: WeProgress(
                  percentage:
                      ((controller.currentPage - 1) /
                              controller.totalPages *
                              100)
                          .clamp(0, 100)
                          .toDouble(),
                  strokeWidth: 5,
                  showText: false,
                ),
              ),
              const Spacer(),
              WeButton(
                text: controller.hasNext ? '加载更多' : '已全部加载',
                icon: controller.hasNext
                    ? Icons.expand_more_rounded
                    : Icons.check_rounded,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                loading: controller.isLoading,
                onPressed: controller.hasNext ? controller.loadNextPage : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget itemBuilder(
    BuildContext context,
    PaginationLoadingController<Order> controller,
    Order item,
  ) => const SizedBox.shrink();

  @override
  Widget loadingIndicator(BuildContext context) => const Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        WeSkeleton(rows: 1, title: false, rowHeight: 36),
        SizedBox(height: 12),
        WeSkeleton.avatarRow(),
        SizedBox(height: 16),
        WeSkeleton.avatarRow(),
        SizedBox(height: 16),
        WeSkeleton.avatarRow(),
        SizedBox(height: 16),
        WeSkeleton.avatarRow(),
      ],
    ),
  );

  @override
  Widget emptyIndicator(BuildContext context) =>
      const EmptyState(title: '还没有订单', description: '下拉可以重新拉取一次');

  void _openDetail(BuildContext context, Order o) {
    final colors = WeTheme.of(context).colors;
    final int step = switch (o.status) {
      OrderStatus.pending => 0,
      OrderStatus.packing => 1,
      OrderStatus.shipped => 2,
      OrderStatus.done => 3,
      OrderStatus.refunding => 1,
    };
    const steps = ['下单支付', '拣货出库', '干线配送', '签收完成'];
    final bool refunding = o.status == OrderStatus.refunding;
    final bool canShip =
        o.status == OrderStatus.pending || o.status == OrderStatus.packing;
    final form = WeFormController();
    final draft = _ShipDraft();

    WeDrawer.show<void>(
      context,
      size: 560,
      resizable: true,
      titleWidget: Row(
        children: [
          Icon(
            o.status.icon,
            size: 20,
            color: colors.semantic(o.status.semantic),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: WeText(
              '订单 ${o.no}',
              size: SizeEnum.large,
              bold: true,
              truncate: true,
            ),
          ),
          const SizedBox(width: 8),
          Tag(
            o.status.label,
            type: o.status.semantic,
            theme: TagThemeEnum.light,
            size: SizeEnum.small,
          ),
        ],
      ),
      beforeClose: () async {
        if (draft.tracking.trim().isEmpty) return true;
        return WeMessageBox.confirm(
          context,
          '运单号还没提交，关闭后需要重新填写。',
          title: '放弃发货信息？',
          confirmText: '放弃',
          type: SemanticEnum.warning,
        );
      },
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          WeAlert(
            title:
                '${o.buyer} 于 ${o.placedAt} 通过${o.channel}下单，发往${o.province}',
            description: '拖动抽屉左边缘可以调整宽度。',
            type: refunding ? SemanticEnum.danger : SemanticEnum.info,
            closable: false,
          ),
          const SizedBox(height: 20),
          WeSteps(
            active: o.status == OrderStatus.done ? steps.length : step,
            alignCenter: true,
            finishStatus: o.status == OrderStatus.done
                ? WeStepStatus.success
                : WeStepStatus.finish,
            steps: [
              for (int i = 0; i < steps.length; i++)
                WeStep(
                  title: steps[i],
                  status: refunding && i == step ? WeStepStatus.error : null,
                  description: refunding && i == step ? '退款处理中' : null,
                ),
            ],
          ),
          const SizedBox(height: 20),
          WeDescriptions(
            columns: 2,
            bordered: true,
            size: SizeEnum.small,
            labelWidth: 80,
            items: [
              WeDescriptionItem('商品', '${o.product} × ${o.quantity}', span: 2),
              WeDescriptionItem('实付金额', '¥${o.amount.toStringAsFixed(2)}'),
              WeDescriptionItem(
                '当前状态',
                '',
                child: Tag(
                  o.status.label,
                  type: o.status.semantic,
                  theme: TagThemeEnum.light,
                  size: SizeEnum.small,
                ),
              ),
              WeDescriptionItem('渠道', o.channel),
              WeDescriptionItem('收货地', o.province),
            ],
          ),
          const WeDivider(text: '履约链路', align: WeDividerAlign.start),
          WeTimeline(
            items: [
              for (int i = 0; i < steps.length; i++)
                WeTimelineItem(
                  title: steps[i],
                  timestamp: i <= step
                      ? '09-20 ${(9 + i * 3).toString().padLeft(2, '0')}:1$i'
                      : '待处理',
                  type: i < step
                      ? SemanticEnum.success
                      : i == step
                      ? (o.status == OrderStatus.refunding
                            ? SemanticEnum.danger
                            : SemanticEnum.primary)
                      : null,
                  hollow: i > step,
                  icon: i < step ? Icons.check_rounded : null,
                  description: i == step && o.status == OrderStatus.refunding
                      ? '买家申请退款，等待客服在 24 小时内处理'
                      : null,
                ),
            ],
          ),
          if (canShip) ...[
            const WeDivider(text: '发货信息', align: WeDividerAlign.start),
            _ShipForm(form: form, draft: draft),
          ],
        ],
      ),
      actions: (drawerContext) => [
        WeButton(
          text: '联系买家',
          icon: Icons.chat_bubble_outline_rounded,
          variant: WeButtonVariant.plain,
          onPressed: () {
            Navigator.of(drawerContext).pop();
            WeMessage.info(context, '已打开与 ${o.buyer} 的会话');
          },
        ),
        if (refunding || canShip)
          WeButton(
            text: refunding ? '同意退款' : '标记已发货',
            type: refunding ? SemanticEnum.danger : SemanticEnum.primary,
            onPressed: () async {
              if (canShip && !await form.validate()) return;
              if (!drawerContext.mounted) return;
              Navigator.of(drawerContext).pop();
              if (!context.mounted) return;
              WeNotification.show(
                context,
                title: refunding ? '已退款' : '已发货',
                message: refunding
                    ? '${o.no} 的款项将在 1-3 个工作日原路退回。'
                    : '${o.no} 已交给${draft.carrier}，运单号 ${draft.tracking}，买家会收到通知。',
                type: SemanticEnum.success,
              );
            },
          ),
      ],
    );
  }
}

/// 发货表单的值；抽屉的按钮和 beforeClose 都要读它。
class _ShipDraft {
  String? carrier;
  String tracking = '';
}

class _ShipForm extends StatefulWidget {
  const _ShipForm({required this.form, required this.draft});

  final WeFormController form;
  final _ShipDraft draft;

  @override
  State<_ShipForm> createState() => _ShipFormState();
}

class _ShipFormState extends State<_ShipForm> {
  static const _carriers = [
    WeSelectGroup('合作快递', [
      WeSelectOption('顺丰速运', '顺丰速运', icon: Icons.local_shipping_outlined),
      WeSelectOption('京东物流', '京东物流', icon: Icons.local_shipping_outlined),
    ]),
    WeSelectGroup('普通快递', [
      WeSelectOption('中通快递', '中通快递'),
      WeSelectOption('圆通速递', '圆通速递'),
      WeSelectOption('韵达快递', '韵达快递'),
      WeSelectOption('邮政 EMS', '邮政 EMS', disabled: true),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return WeForm(
      controller: widget.form,
      labelWidth: 80,
      children: [
        WeFormItem(
          name: 'carrier',
          label: '快递公司',
          value: draft.carrier,
          rules: const [WeRule(required: true, message: '请选择快递公司')],
          child: WeSelect<String>(
            value: draft.carrier,
            hint: '选择或搜索快递公司',
            filterable: true,
            groups: _carriers,
            onChanged: (v) => setState(() => draft.carrier = v),
          ),
        ),
        WeFormItem(
          name: 'tracking',
          label: '运单号',
          value: draft.tracking,
          rules: [
            const WeRule(required: true, message: '请填写运单号'),
            WeRule(
              pattern: RegExp(r'^[A-Za-z0-9]{10,15}$'),
              message: '运单号是 10-15 位字母或数字',
              trigger: WeRuleTrigger.blur,
            ),
          ],
          child: WeInput(
            hint: '例如 SF1234567890',
            clearable: true,
            onChanged: (v) => setState(() => draft.tracking = v),
          ),
        ),
      ],
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.controller});

  final PaginationLoadingController<Order> controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: controller.isLoading
            ? const SizedBox(width: 220, child: WeSkeleton.block(height: 12))
            : WeText(
                controller.hasNext ? '向下滚动加载更多' : '—— 到底了 ——',
                role: WeTextRole.placeholder,
                size: SizeEnum.small,
              ),
      ),
    );
  }
}
