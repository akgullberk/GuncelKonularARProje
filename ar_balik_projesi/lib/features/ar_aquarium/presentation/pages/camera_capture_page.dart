import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../domain/aquarium_entry_mode.dart';
import 'aquarium_page.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({
    super.key,
    required this.entryMode,
  });

  final AquariumEntryMode entryMode;

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'Kamera bulunamadı.';
          _isLoading = false;
        });
        return;
      }

      final selectedCamera = cameras.first;
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Kamera başlatılamadı: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final photo = await controller.takePicture();
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => AquariumPage(
            capturedImagePath: photo.path,
            entryMode: widget.entryMode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf çekilemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryMode == AquariumEntryMode.explore
              ? 'Kesif — Zemin fotografi'
              : 'Oyun — Zemin fotografi',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : controller == null
                  ? const Center(child: Text('Kamera başlatılamadı.'))
                  : Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                            child: CameraPreview(controller),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Telefonu düz zemine tut ve fotoğraf çek.',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _isCapturing ? null : _takePhoto,
                                icon: const Icon(Icons.camera_alt),
                                label: Text(
                                  _isCapturing ? 'Çekiliyor...' : 'Fotoğraf Çek',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
