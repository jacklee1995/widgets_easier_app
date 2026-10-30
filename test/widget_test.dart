import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgets_easier/widgets_easier.dart';
import 'package:widgets_easier_gallery/admin/data/mock_data.dart';
import 'package:widgets_easier_gallery/admin/pages/components_page.dart';
import 'package:widgets_easier_gallery/admin/pages/orders_page.dart';
import 'package:widgets_easier_gallery/admin/pages/products_page.dart';
import 'package:widgets_easier_gallery/main.dart';

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [WeTheme.light()]),
      home: Scaffold(body: page),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('后台外壳渲染出侧边菜单和概览页', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('经营概览'), findsWidgets);
    expect(find.text('组件总览'), findsOneWidget);
  });

  testWidgets('发布新品：空表单提交时逐项报错', (tester) async {
    await _pumpPage(tester, const ProductsPage());
    await tester.tap(find.text('发布新品'));
    await tester.pumpAndSettle();
    expect(find.byType(WeForm), findsOneWidget);

    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    expect(find.text('请填写商品名称'), findsOneWidget);
    expect(find.text('请选择类目'), findsOneWidget);
    expect(find.text('至少上传一张主图'), findsOneWidget);
    expect(find.byType(WeUpload), findsOneWidget);
    expect(find.byType(WeDialog), findsOneWidget, reason: '校验不过不关弹窗');
  });

  testWidgets('商品行删除走 WePopconfirm', (tester) async {
    await _pumpPage(tester, const ProductsPage());
    expect(find.textContaining('共 ${kProducts.length} 个 SKU'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(WePopconfirm), findsWidgets);
    await tester.tap(find.widgetWithText(WeButton, '删除').last);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('共 ${kProducts.length - 1} 个 SKU'),
      findsOneWidget,
    );
    expect(find.textContaining('已从商品库移除'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  group('组件总览的平台区分', () {
    Finder segment(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is WeSegmented),
      matching: find.text(label),
    );

    testWidgets('筛选「手机」后只剩手机卡片', (tester) async {
      await _pumpPage(tester, const ComponentsPage());
      expect(find.text('WeButton'), findsOneWidget);

      await tester.tap(segment('手机'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('WeButton'), findsNothing);
      expect(find.textContaining('没有该平台的组件'), findsOneWidget);

      await tester.tap(find.text('表单'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('CounterInput'), findsOneWidget);
      expect(find.text('WeInput'), findsNothing);
      expect(find.text('WeDatePicker'), findsNothing);
      expect(find.text('WeDateWheel / WeDateSheet'), findsOneWidget);

      await tester.tap(find.text('导航'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('WeTabbar'), findsOneWidget);
      expect(find.text('WeMenu'), findsNothing);

      await tester.tap(segment('全部'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('WeMenu'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

    testWidgets('按手机预览时，日期选择器弹出底部滚轮', (tester) async {
      await _pumpPage(tester, const ComponentsPage());
      await tester.tap(find.text('表单'));
      await tester.pump(const Duration(milliseconds: 400));
      Finder picker() => find
          .descendant(
            of: find.byType(WeDatePicker).first,
            matching: find.byType(TextField),
          )
          .first;

      await tester.ensureVisible(picker());
      await tester.tap(picker());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(WeDatePanel), findsOneWidget, reason: '电脑上是面板');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(WeDatePanel), findsNothing);

      await tester.ensureVisible(find.byKey(const ValueKey('phone-preview')));
      await tester.tap(find.byKey(const ValueKey('phone-preview')));
      await tester.pump(const Duration(milliseconds: 600));
      final int inline = find.byType(WeDateWheel).evaluate().length;
      await tester.ensureVisible(picker());
      await tester.tap(picker());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(WeDatePanel), findsNothing);
      expect(find.byType(WeDateWheel), findsNWidgets(inline + 1));
      expect(find.text('确定'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

    testWidgets('按手机预览：390 宽的框里按触屏尺寸显示', (tester) async {
      await _pumpPage(tester, const ComponentsPage());
      final Finder button = find.widgetWithText(WeButton, 'plain');
      expect(tester.getSize(button).height, 24);
      expect(find.byKey(const ValueKey('phone-frame')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('phone-preview')));
      await tester.pump(const Duration(milliseconds: 400));
      final Finder frame = find.byKey(const ValueKey('phone-frame'));
      expect(frame, findsOneWidget);
      expect(tester.getSize(frame).width, lessThan(420));
      expect(
        tester.getSize(find.descendant(of: frame, matching: button)).height,
        36,
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  });

  testWidgets('订单详情在 WeDrawer 里打开', (tester) async {
    await _pumpPage(tester, const OrdersPage());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(WeLink).first);
    await tester.pumpAndSettle();
    expect(find.byType(WeDrawer), findsOneWidget);
    expect(find.text('履约链路'), findsOneWidget);
    expect(find.byType(WeSteps), findsOneWidget);
  });
}
