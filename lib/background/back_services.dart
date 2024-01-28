import 'dart:async';
import 'dart:ui';
import 'package:pomodoro/notification/end_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initalizeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: false,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsBackgroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isPaused = prefs.getBool('isPaused') ?? false;
  int closeTime = prefs.getInt('closeTime') ?? 0;
  int runningTime = prefs.getInt('runningTime') ?? 0;
  bool finished = false;
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {}
      if (!finished) {
        print((DateTime.now().millisecondsSinceEpoch - closeTime) ~/ 1000);
        if (runningTime <
            (DateTime.now().millisecondsSinceEpoch - closeTime) ~/ 1000) {
          print("finished");
          prefs.setBool('isRunning', false);
          prefs.setBool('isPaused', false);
          NotificationService().showNotification();
          finished = true;
          prefs.setBool('finished', true);
          service.stopSelf();
        }
      }
      // perform some operation on backgorund which is not noticeable to the used everyime
      // service.setForegroundNotificationInfo(title: "Script", content: "asd");
      print("Background 12333");
      service.invoke('update');
    }
  });
}


// if (TimerScreenState.isRunning) {
//         if (TimerScreenState.runningTime <
//             (DateTime.now().millisecondsSinceEpoch -
//                     TimerScreenState.closeTime) ~/
//                 1000) {
//           print("finished");
//           TimerScreenState.isRunning = false;
//           TimerScreenState.isPaused = false;
//           TimerScreenState.runningTime = 0;
//           NotificationService().showNotification();
//           service.stopSelf();
//         }
//       }