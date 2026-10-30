import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../theme_mode.dart';
import '../widgets/docs_widget.dart';

/// 设计 token 总览：切换亮/暗、改品牌色，看组件是否跟着变。
///
/// 这一页同时是 `WeTheme` 的验收页——如果某个组件在这里不跟随主题，说明它
/// 还在用写死的颜色，没迁到 token。
class ThemeDocs extends StatelessWidget {
  final int c;
  const ThemeDocs(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    final WeTheme theme = WeTheme.of(context);
    final WeColorScheme colors = theme.colors;

    return DocsWidget(
      children: [
        Write.header1('$c. 主题与设计 token'),
        Write.paragraph(
          '所有组件的颜色、尺寸、圆角、间距、阴影都来自 WeTheme，它是一个 '
          'ThemeExtension。接入只需要在你已有的 ThemeData 上挂一个扩展：',
        ),
        const _Snippet('''
MaterialApp(
  theme: ThemeData.light().copyWith(extensions: [WeTheme.light()]),
  darkTheme: ThemeData.dark().copyWith(extensions: [WeTheme.dark()]),
)'''),
        Write.paragraph(
          '组件内部用 WeTheme.of(context) 取 token；没挂扩展时会按 '
          'ThemeData.brightness 回退到内置调色板，所以不配置也能跑。',
        ),
        const Gap(16),

        Write.header2('换一个品牌色'),
        Write.paragraph(
          '派生调色板用 copyWith，不需要重新声明四十多个颜色。下面的按钮会实时'
          '改写 primary，页面上所有语义色组件都应该跟着变。',
        ),
        const _BrandColorPicker(),
        const Gap(16),

        Write.header2('语义色 · WeColorScheme.semantic()'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final type in SemanticEnum.values)
              _Swatch(name: type.name, color: colors.semantic(type)),
          ],
        ),
        const Gap(16),

        Write.header2('文字色'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Swatch(name: 'primaryText', color: colors.primaryText),
            _Swatch(name: 'regularText', color: colors.regularText),
            _Swatch(name: 'secondaryText', color: colors.secondaryText),
            _Swatch(name: 'placeholderText', color: colors.placeholderText),
            _Swatch(name: 'disabledText', color: colors.disabledText),
          ],
        ),
        const Gap(16),

        Write.header2('边框色与填充色'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Swatch(name: 'darkerBorder', color: colors.darkerBorder),
            _Swatch(name: 'baseBorder', color: colors.baseBorder),
            _Swatch(name: 'lighterBorder', color: colors.lighterBorder),
            _Swatch(name: 'darkFill', color: colors.darkFill),
            _Swatch(name: 'baseFill', color: colors.baseFill),
            _Swatch(name: 'lighterFill', color: colors.lighterFill),
          ],
        ),
        const Gap(16),

        Write.header2('尺寸 · WeSizeScheme'),
        Write.paragraph(
          '每个 SizeEnum 档位对应一组高度 / 字号 / 内边距 / 间距 / 图标尺寸，'
          '常规控件（按钮、输入框）和紧凑组件（标签、徽标）各一套。',
        ),
        _SizeTable(sizes: theme.sizes),
        const Gap(16),

        Write.header2('跟随主题的组件'),
        Write.paragraph('已迁到 token 的组件（其余组件仍在迁移中）：'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in SizeEnum.values)
              WeButton(text: size.name, size: size, onPressed: () {}),
            WeButton(
              text: 'outlined',
              variant: WeButtonVariant.plain,
              onPressed: () {},
            ),
            const WeButton(text: 'disabled', type: SemanticEnum.secondary),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final type in SemanticEnum.values)
              Tag(type.name, type: type, theme: TagThemeEnum.light),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final tagTheme in TagThemeEnum.values)
              Tag(
                tagTheme.name,
                type: SemanticEnum.primary,
                theme: tagTheme,
                closable: true,
              ),
          ],
        ),
        const Gap(20),
      ],
    );
  }
}

/// 一排预设品牌色，点了就改 [brandColor]。
class _BrandColorPicker extends StatelessWidget {
  const _BrandColorPicker();

  static const List<(String, Color)> _presets = [
    ('Element 蓝', Color(0xFF409EFF)),
    ('翠绿', Color(0xFF13CE66)),
    ('橙', Color(0xFFFF9900)),
    ('玫红', Color(0xFFE6407A)),
    ('靛紫', Color(0xFF7B5CF5)),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: brandColor,
      builder: (context, current, _) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (name, color) in _presets)
            InkWell(
              onTap: () => brandColor.value = color,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    WeTheme.of(context).radius.base,
                  ),
                  border: Border.all(
                    color: color,
                    width: color == current ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(8),
                    Text(name),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 一个色块加它的名字和十六进制值。
class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = WeTheme.of(context).colors;
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                WeTheme.of(context).radius.base,
              ),
              border: Border.all(color: colors.baseBorder),
            ),
          ),
          const Gap(4),
          Text(name, style: TextStyle(fontSize: 12, color: colors.regularText)),
          Text(
            hex,
            style: TextStyle(fontSize: 11, color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}

/// 把 [WeSizeScheme] 的两套档位摊开成一张表。
class _SizeTable extends StatelessWidget {
  final WeSizeScheme sizes;
  const _SizeTable({required this.sizes});

  @override
  Widget build(BuildContext context) {
    final colors = WeTheme.of(context).colors;
    final head = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: colors.primaryText,
    );
    final cell = TextStyle(fontSize: 12, color: colors.regularText);

    TableRow row(String label, WeControlSize s) => TableRow(
      children: [
        for (final text in [
          label,
          '${s.height}',
          '${s.fontSize}',
          '${s.horizontalPadding}',
          '${s.spacing}',
          '${s.iconSize}',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Text(text, style: cell),
          ),
      ],
    );

    return Table(
      border: TableBorder.all(color: colors.lighterBorder),
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
      children: [
        TableRow(
          decoration: BoxDecoration(color: colors.lightFill),
          children: [
            for (final text in [
              '',
              'height',
              'fontSize',
              'padding',
              'spacing',
              'iconSize',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Text(text, style: head),
              ),
          ],
        ),
        for (final size in SizeEnum.values)
          row('control.${size.name}', sizes.control(size)),
        for (final size in SizeEnum.values)
          row('compact.${size.name}', sizes.compact(size)),
      ],
    );
  }
}

/// 等宽字体的代码块。
class _Snippet extends StatelessWidget {
  final String code;
  const _Snippet(this.code);

  @override
  Widget build(BuildContext context) {
    final colors = WeTheme.of(context).colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.lightFill,
        borderRadius: BorderRadius.circular(WeTheme.of(context).radius.base),
        border: Border.all(color: colors.lighterBorder),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: colors.primaryText,
        ),
      ),
    );
  }
}
