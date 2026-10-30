import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import 'mock_data.dart';

/// 示例没有接文件选择插件，[WeUpload] 需要的两个回调在这里模拟：
///
/// - 选图：按顺序从商品库取商品，把它的表情和底色现画成一张 PNG；
/// - 上传：每 120ms 走一格进度，每第 4 次上传在 60% 时模拟断网，方便看重试。
///
/// 真实项目里把 [pickImages] 换成 `file_picker`，把 [upload] 换成 dio 的
/// `onSendProgress` 即可。
class MockUploadService {
  int _picked = 0;
  int _uploads = 0;

  Future<List<WeUploadFile>> pickImages(bool multiple) async {
    final files = <WeUploadFile>[];
    for (int i = 0; i < (multiple ? 2 : 1); i++) {
      final Product p = kProducts[_picked++ % kProducts.length];
      final Uint8List bytes = await _render(p.emoji, p.tint);
      files.add(
        WeUploadFile(name: '${p.sku}.png', size: bytes.length, bytes: bytes),
      );
    }
    return files;
  }

  Future<List<WeUploadFile>> pickDocuments(bool multiple) async {
    const docs = [
      ('9月对账单.xlsx', 86 * 1024),
      ('质检报告.pdf', 1300 * 1024),
      ('营业执照扫描件.pdf', 3600 * 1024),
      ('活动方案.docx', 42 * 1024),
    ];
    final (String name, int size) = docs[_picked++ % docs.length];
    return [WeUploadFile(name: name, size: size)];
  }

  Future<Object?> upload(
    WeUploadFile file,
    ValueChanged<double> onProgress,
  ) async {
    final bool fail = ++_uploads % 4 == 0;
    for (int i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (fail && i == 6) throw Exception('网络中断');
      onProgress(i / 10);
    }
    return 'https://cdn.example.com/${file.name}';
  }
}

final MockUploadService mockUpload = MockUploadService();

/// 商品没有真图，按「表情 + 深浅三种底色」现画三张当主图。
Future<List<Uint8List>> renderProductGallery(Product p) => Future.wait([
  _render(p.emoji, p.tint),
  _render(p.emoji, Color.lerp(p.tint, Colors.white, 0.45)!),
  _render(p.emoji, Color.lerp(p.tint, Colors.black, 0.25)!),
]);

Future<Uint8List> _render(String emoji, Color tint) async {
  const int side = 240;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(
      const Rect.fromLTWH(0, 0, side * 1.0, side * 1.0),
      Paint()..color = tint,
    );
  final painter = TextPainter(
    text: TextSpan(text: emoji, style: const TextStyle(fontSize: 120)),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset((side - painter.width) / 2, (side - painter.height) / 2),
  );
  final ui.Image image = await recorder.endRecording().toImage(side, side);
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  painter.dispose();
  return data!.buffer.asUint8List();
}
