import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import 'charts.dart';

/// 概览页顶部的核心指标卡：数值 + 环比 + 迷你走势 + 目标进度。
class KpiCard extends StatefulWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
    required this.compare,
    required this.icon,
    required this.type,
    required this.trend,
    required this.goal,
    required this.goalLabel,
  });

  final String label;
  final String value;
  final String unit;

  /// 环比百分比，正数向上、负数向下。
  final double delta;
  final String compare;
  final IconData icon;
  final SemanticEnum type;
  final List<double> trend;

  /// 目标完成度，0～1。
  final double goal;
  final String goalLabel;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final we = WeTheme.of(context);
    final colors = we.colors;
    final accent = colors.semantic(widget.type);
    final bool up = widget.delta >= 0;
    final Color deltaColor = up ? colors.success : colors.danger;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: colors.baseBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? accent.withValues(alpha: 0.45)
                : colors.lighterBorder,
          ),
          boxShadow: _hovered ? we.shadows.light : we.shadows.lighter,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(widget.icon, size: 18, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(fontSize: 13, color: colors.secondaryText),
                  ),
                ),
                Sparkline(
                  data: widget.trend,
                  color: accent,
                  width: 70,
                  height: 26,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: colors.primaryText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.unit,
                  style: TextStyle(fontSize: 12, color: colors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 15,
                  color: deltaColor,
                ),
                const SizedBox(width: 3),
                Text(
                  '${up ? '+' : ''}${widget.delta.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: deltaColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.compare,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.placeholderText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 目标完成度用 WeProgress。
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: WeProgress(
                percentage: widget.goal * 100,
                strokeWidth: 6,
                showText: false,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.goalLabel} · 已完成 ${(widget.goal * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 11, color: colors.placeholderText),
            ),
          ],
        ),
      ),
    );
  }
}
