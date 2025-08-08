import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/home/home_degree_graph.dart';
import 'package:ongi/screens/home/home_logo.dart';
import 'package:ongi/screens/home/home_ourfamily_text.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/home/home_donutCapsule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '사용자';
  String _currentView = 'home';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? savedUsername = await PrefsManager.getUserName();
    if (savedUsername != null) {
      setState(() {
        _username = savedUsername;
      });
    }
  }

  void _changeView(String viewName) {
    setState(() {
      _currentView = viewName;
    });
  }

  void _goBackToHome() {
    setState(() {
      _currentView = 'home';
    });
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'graph':
        return _buildGraphView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildGraphView() {
    return Stack(children: [HomeDegreeGraph(onBack: _goBackToHome)]);
  }

  Widget _buildHomeView() {
    return Stack(
      children: [
        Positioned(
          bottom: -MediaQuery.of(context).size.width * 0.6,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 1.5,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: AppColors.ongiLigntgrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(260),
                    topRight: Radius.circular(260),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Background logo (top right)
        const HomeBackgroundLogo(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.13),
            HomeOngiText(username: _username),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            HomeCapsuleSection(onGraphTap: () => _changeView('graph')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.ongiOrange, child: _buildCurrentView()),
      ],
    );
  }
}
