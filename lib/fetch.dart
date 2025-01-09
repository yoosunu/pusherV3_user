// ignore_for_file: non_constant_identifier_names, avoid_print
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class INotification {
  int code;
  String tag;
  String title;
  String link;
  String writer;
  String etc;
  DateTime created_at;

  INotification({
    required this.code,
    required this.tag,
    required this.title,
    required this.link,
    required this.writer,
    required this.etc,
    required this.created_at,
  });

  factory INotification.fromJson(Map<String, dynamic> json) {
    return INotification(
      code: json['code'] ?? 0,
      tag: json['tag'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      writer: json['writer'] ?? '',
      etc: json['etc'] ?? '',
      created_at: DateTime.parse(json['created_at']),
    );
  }
}

class INotificationBG {
  int code;
  String tag;
  String title;
  String link;
  String writer;
  String etc;

  INotificationBG({
    required this.code,
    required this.tag,
    required this.title,
    required this.link,
    required this.writer,
    required this.etc,
  });

  factory INotificationBG.fromJson(Map<String, dynamic> json) {
    return INotificationBG(
      code: json['code'] ?? 0,
      tag: json['tag'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      writer: json['writer'] ?? '',
      etc: json['etc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'tag': tag,
      'title': title,
      'link': link,
      'writer': writer,
      'etc': etc,
    };
  }
}

Future<List<INotificationBG>> fetchInfosBG(Uri url) async {
  List<INotificationBG> fetchedData = [];

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Uint8List bodyBytes = response.bodyBytes;
      String decodedBody = utf8.decode(bodyBytes);
      List<dynamic> datas = jsonDecode(decodedBody);
      for (var data in datas) {
        fetchedData.add(INotificationBG(
          code: data['code'],
          tag: data['tag'],
          title: data['title'],
          link: data['link'],
          writer: data['writer'],
          etc: data['etc'],
        ));
      }

      fetchedData.sort((a, b) => b.code.compareTo(a.code));

      if (fetchedData.length > 30) {
        fetchedData = fetchedData.sublist(0, 30);
      }
    }
  } catch (e) {
    print('Error fetching data: $e');
  }
  return fetchedData;
}
