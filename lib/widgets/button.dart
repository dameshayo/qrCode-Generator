import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Save Button Helper ───────────────────────────────────────

Future<void> saveQrToGallery(BuildContext ctx, GlobalKey key) async {
  try {
    // Request permission
    PermissionStatus status;
    if (defaultTargetPlatform == TargetPlatform.android) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!status.isGranted) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('Permission denied. Cannot save QR code.')));
      }
      return;
    }

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final img = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final result = await ImageGallerySaverPlus.saveImage(
      byteData.buffer.asUint8List(),
      quality: 100,
      name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (ctx.mounted) {
      final success = result['isSuccess'] == true;
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content:
            Text(success ? '✅ QR code saved to gallery!' : '❌ Failed to save.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  } catch (e) {
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
    }
  }
}
