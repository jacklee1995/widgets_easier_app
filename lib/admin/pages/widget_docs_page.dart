import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../../docs/border_docs.dart';
import '../../docs/bottom_sheet_docs.dart';
import '../../docs/button_group_docs.dart';
import '../../docs/buttons_docs.dart';
import '../../docs/card_docs.dart';
import '../../docs/counter_input_docs.dart';
import '../../docs/dialog_docs.dart';
import '../../docs/loading_framework/paginated_loader_docs.dart';
import '../../docs/notify_toast_docs.dart';
import '../../docs/other_widgets_docs.dart';
import '../../docs/picture_docs.dart';
import '../../docs/shadow_docs.dart';
import '../../docs/tag/tag_docs.dart';
import '../../docs/theme_docs.dart';
import '../../docs/tip_toast_docs.dart';
import '../widgets/panel.dart';
import '../widgets/toolbar.dart';

/// 组件文档：这套后台用到的 Widgets Easier 组件，挨个看用法。
class WidgetDocsPage extends StatelessWidget {
  const WidgetDocsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.weColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WePageHeader(
            title: '组件文档',
            description: '上面的后台完全由这些组件搭成，这里是它们各自的用法',
            actions: [
              WeButton(
                text: 'pub.dev',
                size: SizeEnum.small,
                variant: WeButtonVariant.plain,
                type: SemanticEnum.secondary,
                onPressed: () =>
                    WeMessage.info(context, 'pub.dev/packages/widgets_easier'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AlertBanner(
            type: SemanticEnum.info,
            title: '说明',
            message: '文档以介绍为主，个别示例可能落后于最新 API，以组件源码为准。',
          ),
          const SizedBox(height: 16),
          Panel(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: colors.primaryText),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemeDocs(1),
                  BorderDocs(2),
                  ShadowDocs(3),
                  ButtonDocs(4),
                  ButtonGroupDocs(5),
                  CounterInputDocs(6),
                  PictureDocs(7),
                  CardDocs(8),
                  DialogDocs(9),
                  BottomSheetDocs(10),
                  NotifyToastDocs(11),
                  TipToastDocs(12),
                  TagDocs(13),
                  PaginatedLoaderDocs(14),
                  OtherWidgetsDocs(15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
