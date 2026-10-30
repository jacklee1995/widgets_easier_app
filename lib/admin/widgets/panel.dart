import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// 后台里所有内容区块的统一容器：[WeCard] 的薄封装。
///
/// 保留 `title / subtitle / leading / trailing / slivers` 这几个后台常用的
/// 槽位，样式全部走组件库，切暗色或换主色时整页跟着走。
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.padding,
    this.child,
    this.slivers,
    this.footer,
    this.shadow = WeCardShadow.never,
  });

  final String? title;
  final String? subtitle;

  /// 标题前的图标，画在主色淡底的小方块里。
  final IconData? icon;

  /// 自定义标题前的部件；给了就不画 [icon]。
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  /// 标题栏与内容之间的额外行，比如一排筛选标签。
  final List<Widget>? slivers;
  final Widget? footer;
  final WeCardShadow shadow;

  @override
  Widget build(BuildContext context) {
    final we = WeTheme.of(context);
    final colors = we.colors;
    final bool hasHeader = title != null || trailing != null || leading != null;

    Widget? header;
    if (leading != null) {
      header = Row(
        children: [
          leading!,
          SizedBox(width: we.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      );
    }

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (slivers != null) ...[
          ...slivers!,
          if (child != null) SizedBox(height: we.spacing.md),
        ],
        ?child,
      ],
    );

    return WeCard(
      title: leading == null ? title : null,
      subtitle: leading == null ? subtitle : null,
      icon: leading == null ? icon : null,
      header: header,
      extra: leading == null ? trailing : null,
      footer: footer,
      shadow: shadow,
      dividedHeader: false,
      headerPadding: EdgeInsets.fromLTRB(we.spacing.lg, we.spacing.md, 12, 0),
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            we.spacing.lg,
            hasHeader ? we.spacing.md : we.spacing.lg,
            we.spacing.lg,
            we.spacing.lg,
          ),
      child: body,
    );
  }
}

/// 一行 label / value 的紧凑指标，用在卡片底部；就是小号的 [WeStatistic]。
class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.trend,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final double? trend;

  @override
  Widget build(BuildContext context) {
    return WeStatistic(
      title: label,
      value: value,
      valueSize: 15,
      valueColor: valueColor,
      trend: trend,
    );
  }
}

/// 商品缩略图占位：渐变底 + 表情。不依赖外网图片，列表里也不会闪。
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.emoji,
    required this.tint,
    this.size = 44,
    this.radius = 10,
  });

  final String emoji;
  final Color tint;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.26), tint.withValues(alpha: 0.10)],
        ),
        border: Border.all(color: tint.withValues(alpha: 0.28)),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}
