import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'pages/home.dart';
import 'package:pusher/sqldbinit.dart';
import 'package:pusher/fetch.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pusher/notification.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var fetchedData = await FetchUtil.fetchData(); // fetching logic
    DatabaseHelper dbHelper = DatabaseHelper(); // sqlDB init

    Future<int> getMaxCode() async {
      var db = await dbHelper.database;
      var result = await db.rawQuery(
          'SELECT MAX(${DatabaseHelper.columnCode}) as maxCode FROM ${DatabaseHelper.tableName}');
      int maxCode = Sqflite.firstIntValue(result) ?? 0;
      return maxCode;
    }

    await _saveData(); // shared_preferences for rendering

    var codes = fetchedData[0];
    var tags = fetchedData[1];
    var titles = fetchedData[2];
    var sources = fetchedData[3];
    var etcs = fetchedData[4];
    var links = fetchedData[5];
    var timestamps = fetchedData[6];

    int generateUniqueId(int code, String timestamp) {
      String combinedString = '$code$timestamp';
      return combinedString.hashCode.abs();
    }

    int maxCode = await getMaxCode();

    for (var i = 0; i < codes.length; i++) {
      var code = codes[i];
      var tag = tags[i];
      var title = titles[i];
      var source = sources[i];
      var etc = etcs[i];
      var link = links[i];
      var timestamp = timestamps[i];

      if (codes[i] > maxCode) {
        int uniqueId = generateUniqueId(code, timestamp);
        await dbHelper.insertInfo(
          {
            DatabaseHelper.columnCode: code,
            DatabaseHelper.columnTag: tag,
            DatabaseHelper.columnTitle: title,
            DatabaseHelper.columnSource: source,
            DatabaseHelper.columnEtc: etc,
            DatabaseHelper.columnLink: link,
            DatabaseHelper.columnTimeStamp: timestamp,
          },
        );
        await FlutterLocalNotification.showNotification(
            uniqueId, title, '$code $tag $source $etc fetched: $timestamp');
      }
    }

    return Future.value(true);
  });
}

Future<void> _saveData() async {
  var fetchedData = await FetchUtil.fetchData();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  String dataString = json.encode(fetchedData);
  await prefs.setString('nestedList', dataString);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermission();

  // workmanager section
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "periodicTask",
    "simplePeriodicTask",
    frequency: const Duration(minutes: 15),
  );
  _saveData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
