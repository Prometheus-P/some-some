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
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/somesome_result_$timestamp.png');
      await file.writeAsBytes(bytes);

      // 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
      );
    } catch (e) {
      debugPrint('ShareService error: $e');
    }
  }

  /// 텍스트만 공유
  static Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      debugPrint('ShareService shareText error: $e');
    }
  }
}
