import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

Future<bool> exportWorkoutImage({
  required BuildContext context,
  required String imageUrl,
  required String title,
  required String description,
  required String time,
  required String volume,
  // required String sets,
}) async {
  final repaintKey = GlobalKey();
  final networkImageCompleter = Completer<void>();
  final assetImageCompleter = Completer<void>();

  final imageProvider = NetworkImage(imageUrl);
  final imageProvider2 = AssetImage('assets/images/logo.png');

  // Listen to the network image stream
  final stream = imageProvider.resolve(const ImageConfiguration());
  final networkListener = ImageStreamListener(
    (imageInfo, _) {
      if (!networkImageCompleter.isCompleted) networkImageCompleter.complete();
    },
    onError: (exception, stackTrace) {
      if (!networkImageCompleter.isCompleted) networkImageCompleter.complete();
    },
  );
  stream.addListener(networkListener);

  // Listen to the asset image stream
  final stream2 = imageProvider2.resolve(const ImageConfiguration());
  final assetListener = ImageStreamListener(
    (imageInfo, _) {
      if (!assetImageCompleter.isCompleted) assetImageCompleter.complete();
    },
    onError: (exception, stackTrace) {
      if (!assetImageCompleter.isCompleted) assetImageCompleter.complete();
    },
  );
  stream2.addListener(assetListener);

  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: -1000,
      top: -1000,
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
          key: repaintKey,
          child: SizedBox(
            width: 400,
            height: 500,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: 400,
                    height: 500,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(20, 0, 106, 113),
                        Color(0xFF006A71),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.topLeft,
                        child: Opacity(
                          opacity: 0.8,
                          child: Image(
                            image: imageProvider2,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _infoBox("Time", time)),
                          Expanded(child: _infoBox("Volume", volume)),
                          // Expanded(child: _infoBox("Sets", sets)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  try {
    // ✅ Wait until BOTH images finish loading
    await Future.wait([
      networkImageCompleter.future,
      assetImageCompleter.future,
    ]);

    // Wait a bit more to ensure everything is rendered
    await Future.delayed(const Duration(milliseconds: 100));

    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) throw Exception("Could not find render boundary");

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception("Could not get byte data");

    final pngBytes = byteData.buffer.asUint8List();

    final status = await Permission.photos.request();
    if (!status.isGranted) return false;

    final result = await SaverGallery.saveImage(
      pngBytes,
      quality: 100,
      fileName: "workout_export_${DateTime.now().millisecondsSinceEpoch}",
      skipIfExists: false,
    );

    return result.isSuccess == true;
  } catch (e) {
    print("Export error: $e");
    return false;
  } finally {
    stream.removeListener(networkListener);
    stream2.removeListener(assetListener);
    overlayEntry.remove();
  }
}

Widget _infoBox(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
      Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ],
  );
}
