import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';

class PhotoDateScreen extends StatefulWidget {
  const PhotoDateScreen({super.key});

  @override
  State<PhotoDateScreen> createState() => _PhotoDateScreenState();
}

class _PhotoDateScreenState extends State<PhotoDateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(
        child: Padding(padding: const EdgeInsets.all(24)),
      ),
    );
  }
}
