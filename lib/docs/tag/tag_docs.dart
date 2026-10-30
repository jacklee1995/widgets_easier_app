import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../../widgets/docs_widget.dart';
import 'check_tags_example.dart';
import 'dynamic_tags_example.dart';

class TagDocs extends StatelessWidget {
  final int c;
  const TagDocs(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return DocsWidget(
      children: [
        const Gap(20),
        Write.header1('$c. 标签'),
        Write.header2('$c.1 语义类型'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tag('tag', type: SemanticEnum.primary),
            Tag('tag', type: SemanticEnum.secondary),
            Tag('tag', type: SemanticEnum.info),
            Tag('tag', type: SemanticEnum.success),
            Tag('tag', type: SemanticEnum.warning),
            Tag('tag', type: SemanticEnum.danger),
            Tag('tag', type: SemanticEnum.fatal),
          ],
        ),
        const Gap(20),
        Write.header2('$c.2 主题'),
        Write.paragraph(
          'Tag有3个主题，plain、light和dark，默认情况下为palin，正如上一节所展示的那样。下面展示light和dark两个主题：',
        ),
        Write.header3('$c.2.1 light主题'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.primary),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.secondary),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.info),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.success),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.warning),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.danger),
            Tag('tag', theme: TagThemeEnum.light, type: SemanticEnum.fatal),
          ],
        ),
        const Gap(20),
        Write.header3('$c.2.2 dark主题'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.primary),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.secondary),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.info),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.success),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.warning),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.danger),
            Tag('tag', theme: TagThemeEnum.dark, type: SemanticEnum.fatal),
          ],
        ),
        const Gap(20),
        Write.header2('$c.3 圆角'),
        Write.paragraph(
          '默认有一个大小为4的圆角，若要手动修改可以通过指定radius参数。radius参数接受一个double值。例如，设置radius为0则没有圆角：',
        ),
        const Gap(20),
        const Center(child: Tag('radius: 0', radius: 0)),
        const Gap(20),
        Write.header2('$c.4 尺寸'),
        Write.header3('$c.4.1 枚举尺寸'),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tag('SizeEnum.small', size: SizeEnum.small),
            Tag('SizeEnum.defaultSize', size: SizeEnum.defaultSize),
            Tag('SizeEnum.large', size: SizeEnum.large),
          ],
        ),
        const Gap(20),
        Write.header3('$c.4.2 数值尺寸'),
        Write.paragraph('通过height参数可以指定数值作为尺寸。height一经指定，则size失效。例如，指定高度为50：'),
        const Gap(20),
        const Tag('hignt=50', height: 50),
        const Gap(20),
        Write.header3('$c.4.3 收缩属性'),
        const Gap(20),
        Write.paragraph('通过指定shrink属性为flase，可以使一个标签尽可能占满一行：'),
        const Gap(20),
        const Tag('shrink: false', shrink: false),
        const Gap(20),
        Write.header2('$c.5 可关闭标签'),
        Write.paragraph('通过指定 closable: true，将展示一个关闭图标。例如：'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tag('tag', closable: true, type: SemanticEnum.primary),
            Tag('tag', closable: true, type: SemanticEnum.secondary),
            Tag('tag', closable: true, type: SemanticEnum.info),
            Tag('tag', closable: true, type: SemanticEnum.success),
            Tag('tag', closable: true, type: SemanticEnum.warning),
            Tag('tag', closable: true, type: SemanticEnum.danger),
            Tag('tag', closable: true, type: SemanticEnum.fatal),
          ],
        ),
        const Gap(20),
        Write.header2('$c.6 动态编辑标签示例'),
        const Gap(80),
        const DynamicTagsExample(),
        const Gap(80),
        Write.header2('$c.7 可选中标签'),
        Write.paragraph(
          '有时候因为业务需求，我们可能会需要用到类似复选框的标签，但是按钮式的复选框的样式又不满足需求，'
          '此时就可以使用 CheckTag。点击即可在选中与未选中之间切换：选中时为正常标签外观，'
          '未选中时为浅灰色背景、无边框、灰色文字。',
        ),
        Write.header3('$c.7.1 基本用法'),
        Write.paragraph(
          '不传 checked 时组件自行维护状态，通过 initialChecked 指定初始值。'
          'onChanged 在每次切换时收到新值，onChecked / onUnchecked 则只在对应方向的切换时触发。',
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CheckTag('未选中'),
            const CheckTag('已选中', initialChecked: true),
            CheckTag(
              '带回调',
              onChecked: () => debugPrint('checked'),
              onUnchecked: () => debugPrint('unchecked'),
              onChanged: (value) => debugPrint('changed: $value'),
            ),
            const CheckTag('带勾选图标', showCheckIcon: true, initialChecked: true),
          ],
        ),
        const Gap(20),
        Write.header3('$c.7.2 语义类型'),
        Write.paragraph('选中后的颜色由 type 决定，默认为 primary；也可以用 color 指定任意颜色。'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CheckTag('primary', initialChecked: true),
            CheckTag(
              'secondary',
              initialChecked: true,
              type: SemanticEnum.secondary,
            ),
            CheckTag('info', initialChecked: true, type: SemanticEnum.info),
            CheckTag(
              'success',
              initialChecked: true,
              type: SemanticEnum.success,
            ),
            CheckTag(
              'warning',
              initialChecked: true,
              type: SemanticEnum.warning,
            ),
            CheckTag('danger', initialChecked: true, type: SemanticEnum.danger),
            CheckTag('fatal', initialChecked: true, type: SemanticEnum.fatal),
          ],
        ),
        const Gap(20),
        Write.header3('$c.7.3 主题'),
        Write.paragraph('选中态同样支持 plain、light、dark 三种主题，默认为 light。'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CheckTag('plain', initialChecked: true, theme: TagThemeEnum.plain),
            CheckTag('light', initialChecked: true, theme: TagThemeEnum.light),
            CheckTag('dark', initialChecked: true, theme: TagThemeEnum.dark),
          ],
        ),
        const Gap(20),
        Write.header3('$c.7.4 禁用'),
        Write.paragraph('disabled 为 true 时不响应点击与键盘，并以淡化的颜色显示。'),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CheckTag('禁用未选中', disabled: true),
            CheckTag('禁用已选中', disabled: true, initialChecked: true),
          ],
        ),
        const Gap(20),
        Write.header3('$c.7.5 受控用法示例'),
        Write.paragraph(
          '传入 checked 后组件进入受控模式：它只渲染你给的值，不会自行切换，在 onChanged 中更新状态即可。'
          '下面用一组受控 CheckTag 实现多选筛选：',
        ),
        const Gap(20),
        const CheckTagsExample(),
        const Gap(80),
      ],
    );
  }
}
