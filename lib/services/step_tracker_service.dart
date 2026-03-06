import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';
import 'meal_log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(StepTaskHandler());
}

class StepTaskHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepCountSubscription;
  final MealLogService _mealLogService = MealLogService();
  int _lastStepCount = -1;
  int _todayBaseSteps = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      // Initialize Firebase for the background isolate
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Firebase initialization error in background: $e');
    }

    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Check if we need to reset for a new day
      final lastSavedDay = prefs.getString('last_step_day');
      if (lastSavedDay != todayKey) {
        await prefs.setString('last_step_day', todayKey);
        await prefs.setInt('today_base_steps', event.steps);
        _todayBaseSteps = event.steps;
      } else {
        _todayBaseSteps = prefs.getInt('today_base_steps') ?? event.steps;
      }

      final currentStepsToday = event.steps - _todayBaseSteps;
      
      // Only update if steps changed significantly (to save battery/Firestore)
      if (currentStepsToday != _lastStepCount && currentStepsToday >= 0) {
        _lastStepCount = currentStepsToday;
        await _mealLogService.updateSteps(currentStepsToday);
        
        // Notify the UI if needed
        FlutterForegroundTask.updateService(
          notificationTitle: 'Cal AI Tracking',
          notificationText: 'Steps Today: $currentStepsToday',
        );
      }
    } catch (e) {
      print('Error in _onStepCount: $e');
    }
  }

  void _onStepCountError(Object error) {
    print('Pedometer Error: $error');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Not needed since we use a stream
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _stepCountSubscription?.cancel();
  }
}

class StepTrackerService {
  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_tracker',
        channelName: 'Step Tracker Notification',
        channelDescription: 'Ongoing notification for step tracking',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<ServiceRequestResult> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return const ServiceRequestSuccess();
    }

    return FlutterForegroundTask.startService(
      notificationTitle: 'Cal AI',
      notificationText: 'Tracking your daily steps...',
      callback: startCallback,
    );
  }

  static Future<ServiceRequestResult> stop() async {
    return FlutterForegroundTask.stopService();
  }
}
