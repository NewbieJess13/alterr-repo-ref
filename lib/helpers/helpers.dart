import 'dart:convert';
import 'dart:math';
import 'package:alterr/services/localstorage.dart';
import 'package:flutter/services.dart';
import 'package:xml_parser/xml_parser.dart';

class Helpers {
  static Future getConfig() async {
    return json.decode(await rootBundle.loadString('lib/config.json'));
  }

  static Future getToken() async {
    return await LocalStorage.getUserTokenSharedPref();
  }

  static bool isEmoji(String text) {
    RegExp regExp = RegExp(
        r"(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])");
    return regExp.hasMatch(text) && text.trim().length == 2;
  }

  static parseCaption(String caption) {
    return XmlNode.parseString(
      caption,
      returnNodesOfType: <Type>[
        XmlDeclaration,
        XmlDoctype,
        XmlElement,
        XmlText,
      ],
    );
  }

  static randomString() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        32, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
