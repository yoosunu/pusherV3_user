import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'pages/home.dart';
import 'package:pusher_v3/fetch.dart';
import 'package:pusher_v3/notification.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Future<void> postDataBG() async {
      final List<String> urls = [
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=1&menu=2377',
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=2&menu=2377',
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=3&menu=2377',
      ];

      final Uri url =
          Uri.parse('https://backend.apot.pro/api/v1/notifications/');

      List<INotificationBG> scrappedDataBG = [];
      final results = await Future.wait(urls.map(fetchInfosBG));

      for (var result in results) {
        scrappedDataBG.addAll(result);
      }
      for (INotificationBG data in scrappedDataBG) {
        try {
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(data.toJson()), // 데이터를 JSON으로 인코딩
          );

          // 응답 상태 코드 확인
          if (response.statusCode == 201) {
            await FlutterLocalNotification.showNotification(
                data.code,
                data.title,
                '${data.code} ${data.tag} ${data.writer} ${data.etc}');
            print('succeed posting ${data.code}');
          } else {
            print('Request failed with status: ${response.statusCode}');
          }
        } catch (e) {
          print('Post erorr: $e');
        }
      }
    }

    await postDataBG();

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermissionIos();
  FlutterLocalNotification.requestNotificationPermissionAndroid();

  // workmanager section
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "periodicTask",
    "simplePeriodicTask",
    frequency: const Duration(minutes: 15),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PushserV3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(
        title: 'Pusher',
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomePage(title: 'Home'),
      },
    );
  }
}
