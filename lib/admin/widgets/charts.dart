import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// KPI 卡角落里的迷你走势线。
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.width = 96,
    this.height = 34,
  });

  final List<double> data;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(data: data, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final double min = data.reduce(math.min);
    final double max = data.reduce(math.max);
    final double span = max - min == 0 ? 1 : max - min;
    final double dx = size.width / (data.length - 1);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = dx * i;
      final double y =
          size.height - (data[i] - min) / span * (size.height - 4) - 2;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.26), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || !identical(old.data, data);
}

/// 双序列趋势图：柱子是成交额，折线是订单数。
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.bars,
    required this.line,
    required this.labels,
    required this.barColor,
    required this.lineColor,
  });

  final List<double> bars;
  final List<double> line;
  final List<String> labels;
  final Color barColor;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return CustomPaint(
      painter: _TrendPainter(
        bars: bars,
        line: line,
        labels: labels,
        barColor: barColor,
        lineColor: lineColor,
        gridColor: colors.lighterBorder,
        labelColor: colors.placeholderText,
        textDirection: Directionality.of(context),
      ),
      child: const SizedBox(height: 236, width: double.infinity),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.bars,
    required this.line,
    required this.labels,
    required this.barColor,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.textDirection,
  });

  final List<double> bars;
  final List<double> line;
  final List<String> labels;
  final Color barColor;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final TextDirection textDirection;

  static const double _leftGutter = 38;
  static const double _bottomGutter = 22;

  void _text(
    Canvas canvas,
    String s,
    Offset at,
    Color color, {
    bool right = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontSize: 10.5, color: color),
      ),
      textDirection: textDirection,
    )..layout();
    tp.paint(canvas, right ? at.translate(-tp.width, 0) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final plot = Rect.fromLTRB(
      _leftGutter,
      6,
      size.width,
      size.height - _bottomGutter,
    );
    final double barMax = bars.reduce(math.max) * 1.15;
    final double lineMax = line.isEmpty ? 1 : line.reduce(math.max) * 1.3;

    // 四条水平网格 + 左侧刻度。
    const int steps = 4;
    for (int i = 0; i <= steps; i++) {
      final double y = plot.bottom - plot.height / steps * i;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      _text(
        canvas,
        (barMax / steps * i).toStringAsFixed(0),
        Offset(plot.left - 6, y - 7),
        labelColor,
        right: true,
      );
    }

    final double slot = plot.width / bars.length;
    final double barWidth = math.min(18, slot * 0.46);

    for (int i = 0; i < bars.length; i++) {
      final double cx = plot.left + slot * i + slot / 2;
      final double h = bars[i] / barMax * plot.height;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barWidth / 2, plot.bottom - h, barWidth, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [barColor, barColor.withValues(alpha: 0.35)],
          ).createShader(rect.outerRect),
      );
      if (i.isEven || i == bars.length - 1) {
        _text(canvas, labels[i], Offset(cx - 12, plot.bottom + 6), labelColor);
      }
    }

    if (line.isEmpty) return;
    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < line.length; i++) {
      final double cx = plot.left + slot * i + slot / 2;
      final double y = plot.bottom - line[i] / lineMax * plot.height;
      points.add(Offset(cx, y));
      i == 0 ? path.moveTo(cx, y) : path.lineTo(cx, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );
    for (final p in points) {
      canvas.drawCircle(p, 3.6, Paint()..color = lineColor);
      canvas.drawCircle(p, 1.7, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.barColor != barColor ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor;
}

/// 渠道占比环形图，中心显示合计。
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    required this.centerTitle,
    required this.centerValue,
    this.size = 168,
  });

  final List<({String name, double value, Color color})> slices;
  final String centerTitle;
  final String centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              slices: slices,
              gapColor: colors.baseBackground,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                centerTitle,
                style: TextStyle(fontSize: 11.5, color: colors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.slices, required this.gapColor});

  final List<({String name, double value, Color color})> slices;
  final Color gapColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final ring = rect.deflate(size.width * 0.13);
    double start = -math.pi / 2;

    for (final s in slices) {
      final sweep = s.value / total * math.pi * 2;
      canvas.drawArc(
        ring,
        start,
        sweep - 0.024,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.17
          ..strokeCap = StrokeCap.butt
          ..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.slices != slices;
}

/// 品类销售的横向条形行。
class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.name,
    required this.value,
    required this.max,
    required this.color,
  });

  final String name;
  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              name,
              style: TextStyle(fontSize: 12.5, color: colors.regularText),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (value / max).clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => LinearProgressIndicator(
                  value: t,
                  minHeight: 10,
                  backgroundColor: colors.lightFill,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 62,
            child: Text(
              '${value.toStringAsFixed(1)} 万',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 图例小圆点 + 名称 + 数值。
class LegendDot extends StatelessWidget {
  const LegendDot({
    super.key,
    required this.color,
    required this.name,
    required this.value,
  });

  final Color color;
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 12.5, color: colors.regularText),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
