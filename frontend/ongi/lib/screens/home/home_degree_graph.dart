import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/screens/home/home_ourfamily_text_withoutUser.dart';

class HomeDegreeGraph extends StatelessWidget{
  const HomeDegreeGraph({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
    appBar: AppBar(),
    body: Stack(
      children: [
        const HomeOngiTextWithoutUser(),
      ],
    ),
    bottomNavigationBar: const ButtonColumn(),
    );
}
}