import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 결과 화면 공유 서비스
class ShareService {
  /// RepaintBoundary 위젯을 캡처하여 공유
  static Future<void> shareWidget(
    GlobalKey key, {
    required String text,
  }) async {
    try {
      final bytes = await _captureWidget(key);
      if (bytes == null) return;

      final file = await _saveToTempFile(bytes);
      await _shareFile(file, text: text);
    } catch (e) {
      debugPrint('ShareService error: $e');
    }
  }

  /// 공유 카드 위젯을 인스타 스토리 비율로 캡처하여 공유
  static Future<void> shareCard(
    GlobalKey key, {
    required String text,
    String? instagramCaption,
  }) async {
    try {
      final bytes = await _captureWidget(key, pixelRatio: 3.0);
      if (bytes == null) return;

      final file = await _saveToTempFile(bytes, prefix: 'somesome_card');
      await _shareFile(file, text: text);
    } catch (e) {
      debugPrint('ShareService shareCard error: $e');
    }
  }

  /// 위젯 캡처 (고해상도)
  static Future<List<int>?> _captureWidget(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    return byteData.buffer.asUint8List();
  }

  /// 임시 파일로 저장
  static Future<File> _saveToTempFile(
    List<int> bytes, {
    String prefix = 'somesome_result',
  }) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/${prefix}_$timestamp.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// 파일 공유 (SharePlus 사용)
  static Future<void> _shareFile(File file, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: text,
      ),
    );
  }

  /// 텍스트만 공유
  static Future<void> shareText(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint('ShareService shareText error: $e');
    }
  }

  /// 이미지를 바이트로 캡처 (외부에서 사용)
  static Future<List<int>?> captureWidgetToBytes(GlobalKey key) async {
    return _captureWidget(key);
  }
}
