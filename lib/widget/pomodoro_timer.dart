
import 'dart:async';

import 'package:flutter/material.dart';

class PomodoroTimer extends ChangeNotifier{
  // late DateTime _dateTime;
  late String timeFormat;
  late int minute;
  late int second;
  late Timer timer;
  int totalPomodoros = 0;
  late int settedTime;
  static const int fiftyMinutes = 3000;
  int runningTime = fiftyMinutes;
  bool isRunning = false;
  late DateTime closeTime;

  void onTick(Timer timer) {
    if (runningTime == 0) {
      totalPomodoros = totalPomodoros + 1;
      isRunning = false;
      runningTime = settedTime;
      timer.cancel();
    } else {
      runningTime = runningTime - 1;
    }
  }
  void onStartPressed() {
    if (!isRunning) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
        isRunning = true;
    }
  }
  void onPausePressed() {
    if (isRunning) {
      timer.cancel();
      isRunning = false;
    }
  }
  void onResetPress() {
    timer.cancel();
    isRunning = false;
    runningTime = settedTime;
  }
  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split('.').first.substring(2, 7);
  }
}