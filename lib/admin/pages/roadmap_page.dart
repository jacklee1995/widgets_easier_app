import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../nav.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 还没开发的模块统一落到这里：说明排期，而不是甩一个白屏。
class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key, required this.nodeId});

  final String nodeId;

  static const List<WeTimelineItem> _milestones = [
    WeTimelineItem(
      timestamp: '2026 Q3',
      title: '需求评审通过',
      description: '业务方与产品已对齐字段口径，原型进入终审。',
      type: SemanticEnum.success,
      icon: Icons.check_rounded,
    ),
    WeTimelineItem(
      timestamp: '2026 Q4',
      title: '接口联调中',
      description: '数据服务已提供 7 个接口，剩余 3 个在排期。',
      type: SemanticEnum.primary,
      icon: Icons.sync_rounded,
    ),
    WeTimelineItem(
      timestamp: '2027 Q1',
      title: '灰度上线',
      description: '先对 5% 的商家开放，观察两周再全量。',
      type: SemanticEnum.warning,
      hollow: true,
    ),
    WeTimelineItem(
      timestamp: '2027 Q2',
      title: '全量与旧系统下线',
      description: '数据迁移完成后关闭老后台的对应入口。',
      hollow: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(nodeId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WePageHeader(
            title: meta.title,
            description: meta.description,
            tag: const Tag(
              '开发中',
              type: SemanticEnum.warning,
              theme: TagThemeEnum.light,
              size: SizeEnum.small,
            ),
            actions: [
              WeButton(
                text: '订阅上线通知',
                icon: Icons.notifications_active_outlined,
                variant: WeButtonVariant.plain,
                size: SizeEnum.small,
                onPressed: () => WeNotification.show(
                  context,
                  title: '已订阅',
                  message: '「${meta.title}」上线时会第一时间通知你。',
                  type: SemanticEnum.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AlertBanner(
            type: SemanticEnum.info,
            title: '模块状态',
            message: '该模块正在开发，下面是已确认的范围与节奏。可以先用「组件文档」了解可用组件。',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final bool twoUp = box.maxWidth > 980;
              const timeline = Panel(
                title: '上线节奏',
                subtitle: '每个节点完成后会同步到商家公告',
                icon: Icons.flag_outlined,
                trailing: SizedBox(
                  width: 120,
                  child: WeProgress(
                    percentage: 38,
                    strokeWidth: 8,
                    format: _pct,
                  ),
                ),
                child: WeTimeline(items: _milestones),
              );

              final scope = Panel(
                title: '功能范围',
                subtitle: '第一期会交付的能力',
                icon: Icons.checklist_rtl_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Write.paragraph('这一期聚焦在「能看、能查、能导出」，写操作会放到第二期，避免和现有流程冲突。'),
                    Write.unorderedList([
                      Write.listItem('按日 / 周 / 月三个粒度的指标看板；'),
                      Write.listItem('支持按店铺、渠道、品类三个维度下钻；'),
                      Write.listItem('异常指标自动打标并推送到消息中心；'),
                      Write.listItem('明细支持导出 CSV，单次上限 10 万行。'),
                    ]),
                    const WeDivider(margin: EdgeInsets.symmetric(vertical: 14)),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Tag(
                          '需求已锁定',
                          type: SemanticEnum.success,
                          theme: TagThemeEnum.light,
                          size: SizeEnum.small,
                        ),
                        Tag(
                          '依赖数据中台',
                          type: SemanticEnum.warning,
                          theme: TagThemeEnum.light,
                          size: SizeEnum.small,
                        ),
                        Tag(
                          '需要灰度',
                          type: SemanticEnum.info,
                          theme: TagThemeEnum.light,
                          size: SizeEnum.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const WeDescriptions(
                      columns: 1,
                      bordered: true,
                      size: SizeEnum.small,
                      items: [
                        WeDescriptionItem('负责人', '数据产品组 · 林可'),
                        WeDescriptionItem('依赖', '数据中台 v3 · 消息中心'),
                        WeDescriptionItem('预计工时', '46 人日'),
                      ],
                    ),
                  ],
                ),
              );

              if (!twoUp) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [timeline, const SizedBox(height: 16), scope],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 3, child: timeline),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: scope),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Panel(
            title: '数据预览',
            subtitle: '接口接通前这里是空的',
            icon: Icons.table_chart_outlined,
            child: EmptyState(
              title: '还没有可展示的数据',
              description: '接口联调完成后会自动填充',
              action: WeButton(
                text: '查看接口进度',
                type: SemanticEnum.primary,
                size: SizeEnum.small,
                onPressed: () => WeMessage.info(context, '7 / 10 个接口已就绪'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _pct(double p) => '${p.round()}%';
}
