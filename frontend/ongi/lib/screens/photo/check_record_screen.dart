import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/core/app_colors.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ongi/screens/photo/detail_record_screen.dart';

class CheckRecordScreen extends StatefulWidget {
  final String backImagePath;
  final String? frontImagePath;
  final String? address;
  const CheckRecordScreen({
    super.key,
    required this.backImagePath,
    this.frontImagePath,
    this.address,
  });

  @override
  State<CheckRecordScreen> createState() => CheckRecordScreenState();
}

class CheckRecordScreenState extends State<CheckRecordScreen>
    with TickerProviderStateMixin {
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
  String? _address;
  bool _isLocating = false;

  late AnimationController _frontAnimationController;
  late Animation<double> _frontAnimation;
  bool _isFrontAnimating = false;
  String? _animatingFrontImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchLocation();

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

  Future<void> _fetchLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _address = '위치 권한이 필요합니다.';
          _isLocating = false;
        });
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          List<String> addressParts = [];
          
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
            addressParts.add(p.administrativeArea!);
          }
          
          // locality가 administrativeArea와 다를 때만 추가
          if (p.locality != null && 
              p.locality!.isNotEmpty && 
              p.locality != p.administrativeArea) {
            addressParts.add(p.locality!);
          }
        
          if (p.subLocality != null && p.subLocality!.isNotEmpty) {
            addressParts.add(p.subLocality!);
          }
          
          _address = addressParts.join(' ').trim();
          _isLocating = false;
        });
      } else {
        setState(() {
          _address = '주소를 찾을 수 없습니다.';
          _isLocating = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = '위치 정보를 불러올 수 없습니다.';
        _isLocating = false;
      });
    }
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
                    '지금 순간을',
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
                    '공유할까요?',
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
                            // 후면 사진
                            Positioned.fill(
                              child: Image.file(
                                File(widget.backImagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // 전면 사진이 있는 경우
                            if (widget.frontImagePath != null)
                              Positioned(
                                top: 15,
                                left: 15,
                                width: 120,
                                height: 144,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.ongiOrange,
                                      width: 2.5,
                                    ),
                                    borderRadius: BorderRadius.circular(22.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22.5),
                                    child: Image.file(
                                      File(widget.frontImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                            if (_isLocating)
                              const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: CircularProgressIndicator(
                                    color: AppColors.ongiOrange,
                                  ),
                                ),
                              )
                            else if (widget.address != null)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.place,
                                          color: AppColors.ongiOrange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.address!,
                                          style: const TextStyle(
                                            color: AppColors.ongiOrange,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Pretendard',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ongiOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailRecordScreen(
                              backImagePath: widget.backImagePath,
                              frontImagePath: widget.frontImagePath,
                              address: _address,
                              date: DateTime.now(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Pretendard',
                        ),
                      ),
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
