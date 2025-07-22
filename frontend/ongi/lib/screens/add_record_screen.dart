import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/core/app_colors.dart';
import 'dart:io';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => AddRecordScreenState();
}

class AddRecordScreenState extends State<AddRecordScreen> with TickerProviderStateMixin {
  late CameraController controller;
  List<CameraDescription>? cameras;
  bool isInitialized = false;
  bool hasError = false;
  String errorMessage = '';
  int currentCameraIndex = 0;
  CameraController? frontCameraController;
  bool showFrontCamera = false;
  String? backCapturedImagePath;
  bool _isPhotoTaken = false;

  late AnimationController _frontAnimationController;
  late Animation<double> _frontAnimation;
  bool _isFrontAnimating = false;
  String? _animatingFrontImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _frontAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _frontAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _frontAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras != null && cameras!.isNotEmpty) {
        controller = CameraController(
          cameras![currentCameraIndex],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await controller.initialize();

        setState(() {
          isInitialized = true;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = '사용 가능한 카메라가 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = '카메라 오류가 발생했습니다.';
      });
    }
  }

  Future<void> _initializeFrontCamera() async {
    frontCameraController = CameraController(
      cameras![1],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await frontCameraController!.initialize();

    setState(() {
      showFrontCamera = true;
    });
  }

  Future<void> _startFrontAnimation(String imagePath) async {
    _frontAnimationController.reset();

    setState(() {
      _isFrontAnimating = true;
      _animatingFrontImagePath = imagePath;
    });

    _frontAnimationController.forward().then((_) {
      setState(() {
        _isFrontAnimating = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    frontCameraController?.dispose();
    _frontAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('카메라')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    isInitialized = false;
                  });
                  _initializeCamera();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 140),
                const Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    '지금 마음을',
                    style: TextStyle(
                      fontSize: 55,
                      color: AppColors.ongiOrange,
                      fontWeight: FontWeight.w200,
                      height: 1,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    '나눠볼까요?',
                    style: TextStyle(
                      fontSize: 55,
                      color: AppColors.ongiOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1 / 1.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            SizedBox.expand(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: backCapturedImagePath != null
                                    ? SizedBox.expand(
                                        key: const ValueKey('captured_image'),
                                        child: Image.file(
                                          File(backCapturedImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : isInitialized
                                        ? SizedBox.expand(
                                            key: const ValueKey('camera_preview'),
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: controller.value.previewSize?.height ?? 100,
                                                height: controller.value.previewSize?.width ?? 100,
                                                child: CameraPreview(controller),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.expand(
                                            key: ValueKey('camera_loading'),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.ongiOrange,
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                            if (_animatingFrontImagePath != null)
                              AnimatedBuilder(
                                animation: _frontAnimation,
                                builder: (context, child) {
                                  final animationValue = _isFrontAnimating
                                      ? _frontAnimation.value
                                      : 1.0;

                                  final screenWidth = MediaQuery.of(
                                    context,
                                  ).size.width;

                                  final startTop = 0.0;
                                  final startLeft = 0.0;
                                  final startWidth = screenWidth - 32.0;
                                  final startHeight = startWidth / (1 / 1.2);

                                  final endTop = 15.0;
                                  final endLeft = 15.0;
                                  final endWidth = 120.0;
                                  final endHeight = 144.0;

                                  final currentTop = startTop + (endTop - startTop) * animationValue;
                                  final currentLeft = startLeft + (endLeft - startLeft) * animationValue;
                                  final currentWidth = startWidth + (endWidth - startWidth) * animationValue;
                                  final currentHeight = startHeight + (endHeight - startHeight) * animationValue;

                                  return Positioned(
                                    top: currentTop,
                                    left: currentLeft,
                                    child: Container(
                                      width: currentWidth,
                                      height: currentHeight,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: AppColors.ongiOrange,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22.5),
                                        child: Image.file(
                                          File(_animatingFrontImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Opacity(
                    opacity: (_isPhotoTaken || !isInitialized) ? 0.3 : 1.0,
                    child: IconButton(
                      icon: SvgPicture.asset("assets/images/camera_button.svg"),
                      onPressed: (_isPhotoTaken || !isInitialized)
                          ? null
                          : () async {
                              try {
                                setState(() {
                                  _isPhotoTaken = true;
                                });

                                final XFile image = await controller.takePicture();

                                setState(() {
                                  backCapturedImagePath = image.path;
                                });

                                if (currentCameraIndex == 0 && cameras!.length > 1) {
                                  await _initializeFrontCamera();
                                  final XFile frontImage = await frontCameraController!.takePicture();
                                  await _startFrontAnimation(frontImage.path);
                                }
                              } catch (e) {
                                setState(() {
                                  _isPhotoTaken = false;
                                });
                              }
                            },
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            top: 80,
            right: 30,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/close_icon_black.svg',
                width: 28,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              iconSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}
