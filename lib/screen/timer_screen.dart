import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pomodoro/background/back_services.dart';
import 'package:pomodoro/main.dart';
import 'package:pomodoro/notification/end_notification.dart';
import 'package:pomodoro/widget/time_spinner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  late DateTime _dateTime;
  late int minute = 0;
  late int second = 0;
  late Timer timer;
  int totalPomodoros = 0;
  static int settedTime = fiftyMinutes;
  static const int fiftyMinutes = 3000;
  static int runningTime = fiftyMinutes;
  static bool isRunning = false;
  static bool isPaused = false;
  static late int closeTime;

  void onTick(Timer timer) {
    if (runningTime == 0) {
      if (mounted) {
        setState(() {
          totalPomodoros = totalPomodoros + 1;
          isRunning = false;
          runningTime = settedTime;
          isPaused = false;
        });
        NotificationService().showNotification();
      }
      timer.cancel();
    } else {
      if (mounted) {
        setState(() {
          runningTime = runningTime - 1;
        });
      }
    }
  }

  void onStartPressed() {
    if (!isRunning) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
      if (mounted) {
        setState(() {
          isRunning = true;
        });
      }
    }
  }

  void onPausePressed() {
    if (isRunning) {
      timer.cancel();
      if (mounted) {
        setState(() {
          isRunning = false;
          isPaused = true;
        });
      }
    }
  }

  void onResetPress() {
    if (isRunning) {
      timer.cancel();
    }
    if (mounted) {
      setState(() {
        isRunning = false;
        isPaused = false;
        runningTime = settedTime;
      });
    }
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split('.').first.substring(2, 7);
  }

  @override
  void initState() {
    super.initState();
    // backgroundService();
    _dateTime = DateTime(2024, 1, 1, 0, settedTime ~/ 60, settedTime % 60);
    FlutterBackgroundService().invoke('stopService');
    ifFinished();
  }

  void ifFinished() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var finished = prefs.getBool('finished') ?? false;
    print("finished call");
    setState(() {
      if (finished) {
        prefs.setBool('finished', false);
        isRunning = false;
        isPaused = false;
        totalPomodoros = totalPomodoros + 1;
        runningTime = settedTime;
      } else {
        if (isRunning) {
          int gaptime = DateTime.now().millisecondsSinceEpoch - closeTime;
          runningTime = runningTime - (gaptime ~/ 1000);
          if (runningTime < 0) {
            prefs.setBool('finished', false);
            isRunning = false;
            isPaused = false;
            totalPomodoros = totalPomodoros + 1;
            runningTime = settedTime;
          } else {
            print("loadTime $runningTime");
            timer = Timer.periodic(
              const Duration(seconds: 1),
              onTick,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    print("deactive");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isRunning) {
      await prefs.setInt('runningTime', runningTime);
      await prefs.setBool('isRunning', isRunning);
      await prefs.setBool('isPaused', isPaused);
      await prefs.setInt('closeTime', DateTime.now().millisecondsSinceEpoch);
      FlutterBackgroundService().startService();
      FlutterBackgroundService().invoke('setAsBackground');
    }
    closeTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!isRunning && !isPaused) {
              showDialog<String>(
                context: context,
                builder: (context) => Dialog(
                  child: TimePickerSpinner_WithoutHour(
                    time: _dateTime,
                    is24HourMode: true,
                    isShowSeconds: true,
                    alignment: Alignment.center,
                    normalTextStyle: TextStyle(
                        fontSize: 40, color: Colors.black.withOpacity(0.5)),
                    highlightedTextStyle:
                        const TextStyle(fontSize: 40, color: Colors.black),
                    spacing: 90,
                    itemHeight: 110,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      setState(() {
                        _dateTime = time;
                        settedTime = time.minute * 60 + time.second;
                        runningTime = settedTime;
                      });
                    },
                  ),
                ),
              );
            }
          },
          child: Text(
            format(runningTime),
            style: const TextStyle(
              fontSize: 75,
            ),
          ),
        ),
        const SizedBox(
          height: 100,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                onStartPressed();
              },
              style: ElevatedButton.styleFrom(
                shape: const LinearBorder(),
                minimumSize: const Size(100, 100),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 70,
              ),
            ),
            ElevatedButton(
              onPressed: () => onPausePressed(),
              style: ElevatedButton.styleFrom(
                shape: const LinearBorder(),
                minimumSize: const Size(100, 100),
              ),
              child: const Icon(
                Icons.pause_rounded,
                color: Colors.black,
                size: 70,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                onResetPress();
              },
              style: ElevatedButton.styleFrom(
                shape: const LinearBorder(),
                minimumSize: const Size(100, 100),
              ),
              child: const Icon(
                Icons.stop_rounded,
                color: Colors.black,
                size: 70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
