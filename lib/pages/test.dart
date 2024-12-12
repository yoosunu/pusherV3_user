// // ignore_for_file: use_build_context_synchronously
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:intl/intl.dart';
// import 'package:pusher_v3/main.dart';
// import 'package:pusher_v3/notification.dart';
// // import 'package:pusher_v3/notification.dart';
// import 'package:pusher_v3/sqldbinit.dart';

// class TestPage extends StatefulWidget {
//   const TestPage({super.key, required this.title});

//   final String title;

//   @override
//   State<TestPage> createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
//   bool isLoadingGet = true;
//   bool isRunningGet = false;
//   late DateTime timeStampGet;

//   void _onReceiveTaskData(Object data) {
//     if (data is Map<String, dynamic>) {
//       final dynamic timestampMillis = data["timestampMillis"];
//       final bool isRunning = data["IsRunning"];
//       final bool isLoading = data["IsLoading"];
//       DateTime timestamp =
//           DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
//       setState(() {
//         isRunningGet = isRunning;
//         timeStampGet = timestamp;
//         isLoadingGet = isLoading;
//       });
//     }
//   }

//   Future<void> _requestPermissions() async {
//     final NotificationPermission notificationPermission =
//         await FlutterForegroundTask.checkNotificationPermission();
//     if (notificationPermission != NotificationPermission.granted) {
//       await FlutterForegroundTask.requestNotificationPermission();
//     }

//     if (Platform.isAndroid) {
//       if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
//         await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//       }

//       // Use this utility only if you provide services that require long-term survival,
//       // such as exact alarm service, healthcare service, or Bluetooth communication.
//       //
//       // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
//       // Using this permission may make app distribution difficult due to Google policy.
//       if (!await FlutterForegroundTask.canScheduleExactAlarms) {
//         // When you call this function, will be gone to the settings page.
//         // So you need to explain to the user why set it.
//         await FlutterForegroundTask.openAlarmsAndRemindersSettings();
//       }
//     }
//   }

//   void _initService() {
//     FlutterForegroundTask.init(
//       androidNotificationOptions: AndroidNotificationOptions(
//         channelId: 'foreground_service',
//         channelName: 'Foreground Service Notification',
//         channelDescription:
//             'This notification appears when the foreground service is running.',
//         onlyAlertOnce: true,
//         showWhen: true,
//       ),
//       iosNotificationOptions: const IOSNotificationOptions(
//         showNotification: false,
//         playSound: false,
//       ),
//       foregroundTaskOptions: ForegroundTaskOptions(
//         eventAction: ForegroundTaskEventAction.repeat(
//             1800000), // 10분: 600000, 30분: 1800000,
//         autoRunOnBoot: true,
//         autoRunOnMyPackageReplaced: true,
//         allowWakeLock: true,
//         allowWifiLock: true,
//       ),
//     );
//   }

//   void _stopForegroundTask() {
//     FlutterForegroundTask.stopService();
//   }

//   void _restartForegroundTask() {
//     FlutterForegroundTask.restartService();
//   }

//   void _minimizeForegroundTask() {
//     FlutterForegroundTask.minimizeApp();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Add a callback to receive data sent from the TaskHandler.
//     FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Request permissions and initialize the service.
//       _requestPermissions();
//       _initService();
//     });
//   }

//   @override
//   void dispose() {
//     // Remove a callback to receive data sent from the TaskHandler.
//     FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//         actions: [
//           ElevatedButton(
//               onPressed: _minimizeForegroundTask,
//               child: Icon(
//                 Icons.play_arrow,
//                 color: isRunningGet == true ? Colors.red : Colors.grey,
//               ))
//         ],
//       ),
//       body: Center(
//         child: Text(isLoadingGet == true ? 'Loading ...' : '$timeStampGet'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           print('wow');
//           FlutterLocalNotification.showNotification(1, "test", "testBOdy");
//         },
//         tooltip: 'Refresh',
//         child: const Icon(Icons.details),
//       ),
//     );
//   }
// }
