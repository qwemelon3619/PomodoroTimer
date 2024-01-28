import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pomodoro/notification/end_notification.dart';
import 'background/back_services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro/screen/analysis_screen.dart';
import 'package:pomodoro/screen/timer_screen.dart';

void main() async {
  print("start");
  final notificationService = NotificationService();
  WidgetsFlutterBinding.ensureInitialized();
  await notificationService.init();
  await initalizeService();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _activePage = 0;
  void onItemTapped(int index) {
    setState(() {
      _activePage = index;
    });
  }

  final List<Widget> widgetOptions = [
    const TimerScreen(),
    const AnalysisScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: Scaffold(
        appBar: AppBar(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              label: 'Pomodoro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq_rounded),
              label: 'Record',
            ),
          ],
          currentIndex: _activePage,
          selectedItemColor: Colors.amber,
          onTap: onItemTapped,
        ),
        body: widgetOptions.elementAt(_activePage),
      ),
    );
  }
}
