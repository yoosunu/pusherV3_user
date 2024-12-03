// ignore_for_file: camel_case_types, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pusher/sqldbinit.dart';
import 'save.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _sqlDBPageState();
}

class _sqlDBPageState extends State<HomePage> {
  DatabaseHelper dbHelper = DatabaseHelper();

  late List<dynamic> fetchedData;
  List<List<dynamic>>? _nestedList;

  late dynamic codesGet = [];
  late dynamic tagsGet = [];
  late dynamic titlesGet = [];
  late dynamic sourcesGet = [];
  late dynamic etcsGet = [];
  late dynamic linksGet = [];
  late dynamic timeStampGet = ["Loading..."];

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('nestedList');

    if (storedData != null) {
      setState(() {
        _nestedList = json.decode(storedData).cast<List<dynamic>>();
        codesGet = _nestedList![0];
        tagsGet = _nestedList![1];
        titlesGet = _nestedList![2];
        sourcesGet = _nestedList![3];
        etcsGet = _nestedList![4];
        linksGet = _nestedList![5];
        timeStampGet = _nestedList![6];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void showPopup(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: UniqueKey(),
          title: Text(
            "${titlesGet[index]}",
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SizedBox(
              width: 300,
              height: 220,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: Colors.deepPurple[300],
                          size: 26,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          tagsGet[index],
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Row(children: [
                      Icon(
                        Icons.apartment_rounded,
                        color: Colors.deepPurple[300],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        sourcesGet[index],
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Row(children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.deepPurple[300],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        etcsGet[index],
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    child: Row(children: [
                      Icon(
                        Icons.more_time,
                        color: Colors.deepPurple[300],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        timeStampGet[index],
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ]),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 60.0),
                      ),
                    ),
                    onPressed: () async {
                      final Uri url = Uri.parse(
                          'https://www.jbnu.ac.kr/web/Board/${linksGet[index]}/detailView.do?pageIndex=1&menu=2377');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'https://www.jbnu.ac.kr/web/Board/${linksGet[index]}/detailView.do?pageIndex=1&menu=2377';
                      }
                    },
                    child: const Text(
                      'Go to site to check!',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
              ),
              onPressed: () async {
                await dbHelper.saveNotification({
                  DatabaseHelper.secondColumnCode: codesGet[index],
                  DatabaseHelper.secondColumnTag: tagsGet[index],
                  DatabaseHelper.secondColumnTitle: titlesGet[index],
                  DatabaseHelper.secondColumnSource: sourcesGet[index],
                  DatabaseHelper.secondColumnEtc: etcsGet[index],
                  DatabaseHelper.secondColumnLink: linksGet[index],
                  DatabaseHelper.secondColumnTimeStamp: timeStampGet[index],
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notice has been saved'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Clear database?'),
                  action: SnackBarAction(
                    label: 'CLEAR',
                    onPressed: () async {
                      await dbHelper.resetTable();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
          const Padding(padding: EdgeInsets.all(12))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 50),
                    backgroundColor: Colors.purple[50],
                  ),
                  onPressed: () {},
                  child: Text(
                    "Updated: ${timeStampGet[0]}",
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white10,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: Alignment.center,
                child: ListView.builder(
                  itemCount: codesGet.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 55),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          showPopup(context, index);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${codesGet[index]}',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(10)),
                            Expanded(
                              child: Text(
                                '${titlesGet[index]}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PusherPage(title: "Saved")),
          );
        },
        tooltip: 'Fetch',
        child: const Icon(Icons.save_alt),
      ),
    );
  }
}
