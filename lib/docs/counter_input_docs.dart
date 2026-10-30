import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:gap/gap.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../widgets/docs_widget.dart';

class CounterInputDocs extends StatelessWidget {
  final int c;
  const CounterInputDocs(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return DocsWidget(
      children: [
        Write.header1('$c. 加减输入器'),
        Write.header2('$c.1 使用语义'),
        Write.paragraph('和其它组件一样，通过type属性可以指定语义枚举值，以得到不同的语义色彩。'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HighlightView(
              '''CounterInput(type: SemanticEnum.primary),''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(type: SemanticEnum.primary),
          ],
        ),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                CounterInput(type: SemanticEnum.secondary),
                Text('Secondary'),
              ],
            ),
            Column(
              children: [
                CounterInput(type: SemanticEnum.info),
                Text('Info'),
              ],
            ),
            Column(
              children: [
                CounterInput(type: SemanticEnum.success),
                Text('Success'),
              ],
            ),
          ],
        ),
        const Gap(20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                CounterInput(type: SemanticEnum.warning),
                Text('Warning'),
              ],
            ),
            Column(
              children: [
                CounterInput(type: SemanticEnum.danger),
                Text('Danger'),
              ],
            ),
            Column(
              children: [
                CounterInput(type: SemanticEnum.fatal),
                Text('fatal'),
              ],
            ),
          ],
        ),
        Write.header2('$c.2 自定义色彩'),
        Write.paragraph('如果你想更加灵活地指定各个部分的颜色，这也是可行的。具体来说，有以下几个颜色参数：'),
        Write.orderedList([
          Write.listItem('iconColor：加减图标的颜色'),
          Write.listItem('backgroundColor：输入框背景色；'),
          Write.listItem('buttonColor：按钮颜色；'),
          Write.listItem('textColor：输入框文本颜色。'),
        ]),
        Write.paragraph('下面是一个例子：'),
        Row(
          children: [
            HighlightView(
              '''const CounterInput(
  size: SizeEnum.small,
  iconColor: Colors.amber,
  backgroundColor: Colors.black,
  buttonColor: Colors.blue,
  textColor: Colors.white,
)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(
              size: SizeEnum.small,
              iconColor: Colors.amber,
              backgroundColor: Colors.black,
              buttonColor: Colors.blue,
              textColor: Colors.white,
            ),
          ],
        ),
        Write.header2('$c.3 尺寸'),
        Write.header3('$c.3.1 枚举尺寸'),
        Write.paragraph(
          '通过size组件可以指定尺寸枚举，包括SizeEnum.small、SizeEnum.defaultSize、SizeEnum.large，如果未指定，默认为SizeEnum.defaultSize。',
        ),
        Row(
          children: [
            Column(
              children: [
                CounterInput(
                  size: SizeEnum.small,
                  controller: CounterInputController(),
                ),
                const Text('SizeEnum.small'),
              ],
            ),
            Column(
              children: [
                CounterInput(
                  size: SizeEnum.defaultSize,
                  controller: CounterInputController(),
                ),
                const Text('SizeEnum.defaultSize'),
              ],
            ),
            Column(
              children: [
                CounterInput(
                  size: SizeEnum.large,
                  controller: CounterInputController(),
                ),
                const Text('izeEnum.large'),
              ],
            ),
          ],
        ),
        Write.header3('$c.3.2 数值尺寸'),
        CounterInput(height: 50, controller: CounterInputController()),
        Write.header3('$c.3.3 自动宽度和固定宽度'),
        Write.paragraph(
          '默认情况下宽度是自动的，加减器文本输入区的宽度随着位数的增加而增加。但是也可以通过textFieldWidth指定一个固定的文本输入区宽度。例如：',
        ),
        CounterInput(textFieldWidth: 60, controller: CounterInputController()),
        Write.header2('$c.4 轮廓型加减器'),
        Write.paragraph('通过指定isOutlined的值为true，可以设置加减器为轮廓型。'),
        Row(
          children: [
            CounterInput(
              type: SemanticEnum.primary,
              controller: CounterInputController(),
              isOutlined: true,
            ),
            CounterInput(
              type: SemanticEnum.secondary,
              controller: CounterInputController(),
              isOutlined: true,
            ),
            CounterInput(
              type: SemanticEnum.info,
              controller: CounterInputController(),
              isOutlined: true,
            ),
            CounterInput(
              type: SemanticEnum.success,
              controller: CounterInputController(),
              isOutlined: true,
            ),
          ],
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CounterInput(
              type: SemanticEnum.warning,
              controller: CounterInputController(),
              isOutlined: true,
            ),
            CounterInput(
              type: SemanticEnum.danger,
              controller: CounterInputController(),
              isOutlined: true,
            ),
            CounterInput(
              type: SemanticEnum.fatal,
              controller: CounterInputController(),
              isOutlined: true,
            ),
          ],
        ),
        Write.header2('$c.5 圆角加减器'),
        Write.paragraph('通过radius属性可以很方便地为加减器设置圆角.例如:'),
        Row(
          children: [
            HighlightView(
              '''CounterInput(
  type: SemanticEnum.info,
  controller: CounterInputController(),
  radius: 20,
  step: 3,
)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(type: SemanticEnum.info, radius: 20, step: 3),
          ],
        ),
        Write.header2('$c.6 步进单位'),
        Write.paragraph('通过step属性，可以指定步进单位。步进单位是每次增加或者减少的最小单位。'),
        Write.paragraph('例如'),
        Row(
          children: [
            HighlightView(
              '''const CounterInput(step: 3),''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(step: 3),
          ],
        ),
        Write.header2('$c.7 加减回调'),
        Write.paragraph('加回调用于监听值增加事件，当数值增加时触发；类似地，减回调用于监听减少事件，当数值减少时触发。'),
        Write.unorderedList([
          Write.listItem('通过onIncrement回调，用于监值增加事件；'),
          Write.listItem('通过Decremented回调，用于监值减少事件。'),
        ]),
        Write.paragraph('下面这个例子中，初始值为7，步进值为2，当增加或者减少时在控制台打印新值和旧值：'),
        CounterInput(
          controller: CounterInputController(),
          step: 2,
          onIncrement: (oldValue, value) {
            debugPrint('+增加前为$oldValue；增加后为：$value');
          },
          onDecrement: (oldValue, value) {
            debugPrint('-减少前为$oldValue；减少后为：$value');
          },
        ),
        Write.header2('$c.8 最值与最值回调'),
        Write.paragraph(
          '加减器有一个最大值和一个最小值，默认情况下最小值为0，最大值为100。当变化到最小值时，将触发最小值回调。',
        ),
        Write.paragraph(
          '下面的例子展示了到达最大/最小值时，执行相关回调。其中设置最大值为10，最小值为1，初始值为6，步进值为2。每当到达最小或最大值的时候弹窗提示。',
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HighlightView(
              '''CounterInput(
  type: SemanticEnum.primary,
  minValue: 1,
  maxValue: 10,
  controller: CounterInputController(),
  step: 1,
  onIncrement: (oldValue, value) {
    debugPrint("+Increasing from \$oldValue to \$value");
  },
  onDecrement: (oldValue, value) {
    debugPrint("-Decreasing from \$oldValue to \$value");
  },
  onMax: () => WeMessageBox.alert(context, 'Reached maximum value'),
  onMin: () => WeMessageBox.alert(context, 'Reached minimum value'),
)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            CounterInput(
              type: SemanticEnum.primary,
              minValue: 1,
              maxValue: 10,
              controller: CounterInputController(),
              step: 1,
              onIncrement: (oldValue, value) {
                debugPrint('+Increasing from $oldValue to $value');
              },
              onDecrement: (oldValue, value) {
                debugPrint('-Decreasing from $oldValue to $value');
              },
              onMax: () => WeMessageBox.alert(context, 'Reached maximum value'),
              onMin: () => WeMessageBox.alert(context, 'Reached minimum value'),
            ),
          ],
        ),
        Write.paragraph(
          '需要指出的是.最值回调仅仅是变化到改最值得时候触发，并不处理溢出事件。如果你需要处理溢出，则需要改用对应的溢出回调。',
        ),
        Write.paragraph('另外一点是,在处理最值的时候由于'),
        const Gap(20),
        Write.header2('$c.9 溢出回调'),
        Write.paragraph(
          '溢出回调包括最小值溢出回调和最大值溢出回调。最小值溢出回调指的是，当前已经是最小值了，继续点击减号时执行的回调函数；最大值溢出回调指的是，当前已经是最大值了，继续点击加号时执行的回调函数。这两个回调在已经达到最值的时候提醒用户无法继续相关操作时特别有用。',
        ),
        Write.paragraph('例如：'),
        const Gap(40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HighlightView(
              '''CounterInput(
  type: SemanticEnum.primary,
  minValue: 1,
  maxValue: 13,
  controller: CounterInputController(initialValue: 7),
  step: 4,
  onMinOverflow: () => WeMessageBox.alert(context, '当前已经是最小值，无法继续减少'),
  onMaxOverflow: () => WeMessageBox.alert(context, '当前已经是最大值，无法继续增加'),
)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(40),
            CounterInput(
              type: SemanticEnum.primary,
              minValue: 1,
              maxValue: 13,
              controller: CounterInputController(initialValue: 7),
              step: 4,
              onMinOverflow: () =>
                  WeMessageBox.alert(context, '当前已经是最小值，无法继续减少'),
              onMaxOverflow: () =>
                  WeMessageBox.alert(context, '当前已经是最大值，无法继续增加'),
            ),
          ],
        ),
        const Gap(40),
        Write.header2('$c.10 变化监听器'),
        Write.paragraph('监听器是一个用于监听加减器内部值改变的回调函数，它在数值变化时被调用。'),
        Write.paragraph(
          '监听器通过onValueChanged参数指定。无论值是来自按钮、键盘还是手动输入，它都会收到变化前和变化后两个参数。',
        ),
        const Gap(20),
        CounterInput(
          onValueChanged: (oldValue, newValue) {
            debugPrint('oldValue is $oldValue, newValue is $newValue');
          },
        ),
        Write.header2('$c.11 小数与精度'),
        Write.paragraph(
          '步进值可以是小数。加减器会自动按step、minValue、maxValue推断出需要的小数位数并按此取整，'
          '因此连续点击0.1不会累积出0.30000000000000004这样的浮点误差。',
        ),
        Row(
          children: [
            HighlightView(
              '''const CounterInput(step: 0.1, maxValue: 1)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(step: 0.1, maxValue: 1),
          ],
        ),
        const Gap(20),
        Write.paragraph(
          '如果需要固定显示位数（例如金额always保留两位），用decimals显式指定。此时输入框也会限制最多输入这么多位小数。',
        ),
        Row(
          children: [
            HighlightView(
              '''const CounterInput(
  type: SemanticEnum.success,
  decimals: 2,
  step: 0.25,
  maxValue: 20,
)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(
              type: SemanticEnum.success,
              decimals: 2,
              step: 0.25,
              maxValue: 20,
            ),
          ],
        ),
        Write.header2('$c.12 负数范围'),
        Write.paragraph('当minValue为负时，输入框接受负号，键盘也会带上正负号键。'),
        const CounterInput(
          type: SemanticEnum.warning,
          minValue: -50,
          maxValue: 50,
          step: 5,
        ),
        Write.header2('$c.13 键盘与只读'),
        Write.paragraph(
          '输入框获得焦点后，可以用方向键上/下按step增减。输入过程中不会被强行夹取到区间内，'
          '只有在回车提交或失去焦点时才会规范化，因此在最小值为10时也能正常输入15。',
        ),
        Write.paragraph('如果只想通过按钮改值、禁止键盘输入，把readOnly设为true：'),
        Row(
          children: [
            HighlightView(
              '''const CounterInput(readOnly: true, maxValue: 10)''',
              language: 'dart',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
            ),
            const Gap(20),
            const CounterInput(readOnly: true, maxValue: 10),
          ],
        ),
        const Gap(20),
        Write.paragraph('而enabled为false时整个组件都不再响应交互：'),
        const CounterInput(enabled: false),
        const Gap(20),
      ],
    );
  }
}
