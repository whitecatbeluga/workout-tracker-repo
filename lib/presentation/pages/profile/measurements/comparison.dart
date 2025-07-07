import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';

class ComparisonImagePage extends StatefulWidget {
  final Measurement before;
  final Measurement after;

  const ComparisonImagePage({
    super.key,
    required this.before,
    required this.after,
  });

  @override
  State<ComparisonImagePage> createState() => _ComparisonImagePageState();
}

class _ComparisonImagePageState extends State<ComparisonImagePage> {
  final GlobalKey _globalKey = GlobalKey();
  bool _imagesPrecached = false;
  bool isDownloading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  Future<void> _precacheImages() async {
    try {
      await precacheImage(NetworkImage(widget.before.imageUrl!), context);
      await precacheImage(NetworkImage(widget.after.imageUrl!), context);
    } catch (e) {
      print("Error precaching images: $e");
    }
  }

  Future<void> _checkPermissions() async {
    print("=== Permission Status ===");
    print("Storage: ${await Permission.storage.status}");
    print("Photos: ${await Permission.photos.status}");
    print(
      "ManageExternalStorage: ${await Permission.manageExternalStorage.status}",
    );
    print("========================");
  }

  Future<void> _downloadImage() async {
    setState(() => isDownloading = true);
    print("Downloading image...");

    // Debug: Check current permission status
    await _checkPermissions();

    try {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Check Android version and request appropriate permissions
      bool permissionGranted = false;

      // Try a simpler approach - just request what we need
      try {
        // For newer Android versions, try photos permission first
        PermissionStatus photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          permissionGranted = true;
          print("Photos permission granted");
        } else {
          // Fallback to storage permission
          PermissionStatus storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            permissionGranted = true;
            print("Storage permission granted");
          } else {
            print(
              "Both permissions denied: Photos=$photosStatus, Storage=$storageStatus",
            );
          }
        }
      } catch (e) {
        print("Error requesting permissions: $e");
      }

      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission denied. Please enable it in app settings.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Check if the widget is still mounted and the key context exists
      if (!mounted || _globalKey.currentContext == null) {
        print("Widget not mounted or context null");
        return;
      }

      RenderRepaintBoundary? boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        print("Boundary is null");
        return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final result = await SaverGallery.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 100,
          fileName:
              "progress_comparison_${DateTime.now().millisecondsSinceEpoch}",
          skipIfExists: false,
        );

        if (mounted) {
          setState(() => isDownloading = false);
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image saved to gallery!')),
            );
            Navigator.pushNamed(context, '/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save image.')),
            );
          }
        }
      }
    } catch (e) {
      print("Error saving image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final before = widget.before;
    final after = widget.after;

    return Scaffold(
      appBar: AppBar(title: const Text("Before & After")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF48A6A7),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(child: Image.asset('assets/images/logo.png')),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "BEFORE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                ),
                                child: SizedBox(
                                  height: 300,
                                  child: Image.network(
                                    before.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.error, size: 50),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('MMM yyyy').format(before.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "AFTER",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                ),
                                child: SizedBox(
                                  height: 300,
                                  child: Image.network(
                                    after.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.error, size: 50),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('MMM yyyy').format(after.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Button(
              isLoading: isDownloading,
              label: 'Download Image',
              onPressed: _downloadImage,
              prefixIcon: Icons.download,
            ),
          ],
        ),
      ),
    );
  }
}
