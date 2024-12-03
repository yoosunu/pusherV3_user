import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class FetchUtil {
  static Future fetchData() async {
    // fetching section
    var extractedData = []; // total data

    var codesGet = [];
    var tagsGet = [];
    var titlesGet = [];
    var sourcesGet = [];
    var etcsGet = [];
    var linksGet = [];
    var timesGet = [];

    int timeCode = DateTime.now().millisecondsSinceEpoch;
    String formattedTime =
        DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(timeCode));

    var url = Uri.parse(
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=1&menu=2377');
    var url2 = Uri.parse(
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=2&menu=2377');
    var url3 = Uri.parse(
        'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=3&menu=2377');
    var response = await http.get(url);
    var response2 = await http.get(url2);
    var response3 = await http.get(url3);

    if (response.statusCode == 200) {
      var etcs = [];
      // page 1
      var document = parser.parse(response.body);
      var noticesPage1 = document.getElementsByTagName('tbody');
      for (var noticePage1 in noticesPage1) {
        var trs = noticePage1
            .getElementsByClassName('tr-normal'); // for the length of for loop.
        var nums = noticePage1.getElementsByClassName('brd-num');
        var tags = noticePage1.getElementsByClassName('tag-type-01');
        var titles = noticePage1.getElementsByClassName('title');
        for (var tr in trs) {
          etcs.add(tr.querySelector('ul li'));
        }
        var sources = noticePage1.getElementsByClassName('brd-writer');
        var anchorTags =
            document.querySelectorAll('a[onclick^="pf_DetailMove"]');

        for (var i = 0; i < trs.length; i++) {
          var num = nums[i].text.trim();
          int numInt = int.parse(num);
          var tag = tags[i].text.trim();
          var title = titles[i].text.trim();
          var etc = etcs[i].text.trim();
          var source = sources[i].text.trim();

          codesGet.add(numInt);
          tagsGet.add(tag);
          titlesGet.add(title);
          sourcesGet.add(source);
          etcsGet.add(etc);
          timesGet.add(formattedTime);
        }

        for (var anchorTag in anchorTags) {
          String? onclick = anchorTag.attributes['onclick'];

          if (onclick != null) {
            RegExp regExp = RegExp(r"pf_DetailMove\('(\d+)'\)");
            Match? match = regExp.firstMatch(onclick);

            if (match != null) {
              String id = match.group(1)!;
              linksGet.add(id);
            }
          }
        }
      }

      // page 2
      var document2 = parser.parse(response2.body);
      var noticesPage2 = document2.getElementsByTagName('tbody');
      for (var noticePage2 in noticesPage2) {
        var trs = noticePage2
            .getElementsByClassName('tr-normal'); // for the length of for loop.
        var nums = noticePage2.getElementsByClassName('brd-num');
        var tags = noticePage2.getElementsByClassName('tag-type-01');
        var titles = noticePage2.getElementsByClassName('title');
        for (var tr in trs) {
          etcs.add(tr.querySelector('ul li'));
        }
        var sources = noticePage2.getElementsByClassName('brd-writer');
        var anchorTags =
            document.querySelectorAll('a[onclick^="pf_DetailMove"]');

        for (var i = 0; i < trs.length; i++) {
          var num = nums[i].text.trim();
          int numInt = int.parse(num);
          var tag = tags[i].text.trim();
          var title = titles[i].text.trim();
          var etc = etcs[i].text.trim();
          var source = sources[i].text.trim();

          codesGet.add(numInt);
          tagsGet.add(tag);
          titlesGet.add(title);
          sourcesGet.add(source);
          etcsGet.add(etc);
          timesGet.add(formattedTime);
        }
        for (var anchorTag in anchorTags) {
          String? onclick = anchorTag.attributes['onclick'];

          if (onclick != null) {
            RegExp regExp = RegExp(r"pf_DetailMove\('(\d+)'\)");
            Match? match = regExp.firstMatch(onclick);

            if (match != null) {
              String id = match.group(1)!;
              linksGet.add(id);
            }
          }
        }
      }

      // page 3
      var document3 = parser.parse(response3.body);
      var noticesPage3 = document3.getElementsByTagName('tbody');
      for (var noticePage3 in noticesPage3) {
        var trs = noticePage3
            .getElementsByClassName('tr-normal'); // for the length of for loop.
        var nums = noticePage3.getElementsByClassName('brd-num');
        var tags = noticePage3.getElementsByClassName('tag-type-01');
        var titles = noticePage3.getElementsByClassName('title');
        for (var tr in trs) {
          etcs.add(tr.querySelector('ul li'));
        }
        var sources = noticePage3.getElementsByClassName('brd-writer');
        var anchorTags =
            document.querySelectorAll('a[onclick^="pf_DetailMove"]');

        for (var i = 0; i < trs.length; i++) {
          var num = nums[i].text.trim();
          int numInt = int.parse(num);
          var tag = tags[i].text.trim();
          var title = titles[i].text.trim();
          var etc = etcs[i].text.trim();
          var source = sources[i].text.trim();

          codesGet.add(numInt);
          tagsGet.add(tag);
          titlesGet.add(title);
          sourcesGet.add(source);
          etcsGet.add(etc);
          timesGet.add(formattedTime);
        }
        for (var anchorTag in anchorTags) {
          String? onclick = anchorTag.attributes['onclick'];

          if (onclick != null) {
            RegExp regExp = RegExp(r"pf_DetailMove\('(\d+)'\)");
            Match? match = regExp.firstMatch(onclick);

            if (match != null) {
              String id = match.group(1)!;
              linksGet.add(id);
            }
          }
        }
      }

      extractedData.add(codesGet);
      extractedData.add(tagsGet);
      extractedData.add(titlesGet);
      extractedData.add(sourcesGet);
      extractedData.add(etcsGet);
      extractedData.add(linksGet);
      extractedData.add(timesGet);
    }
    return extractedData;
  }
}
