import 'dart:convert';
import 'dart:typed_data';
import 'package:alterr/helpers/helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/controllers/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiService {
  String? token;
  Future<dynamic> request(String url, Map<String, dynamic> data, String type,
      {withToken = false, returnError = false}) async {
    dynamic body;

    Map<String, dynamic> config = await Helpers.getConfig();
    bool hasConnection = await checkServer(config['api_url']);
    if (hasConnection) {
      String fullUrl = config['api_url'] + url;
      Uri uri = Uri.parse(fullUrl);
      http.Request request = new http.Request(type.toUpperCase(), uri);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      if (withToken) {
        token = await Helpers.getToken();
        headers['Authorization'] = 'Bearer $token';
      }

      request.headers.addAll(headers);
      request.body = jsonEncode(data);

      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        if (response.statusCode == 401) {
          if (type == 'GET') {
            Get.find<AuthController>().signOut();
          }
          return null;
        }
        if (returnError) return Future.error(body);

        String errorMessages = '';
        if (body['errors'] != null) {
          List errorsList = List.from(body['errors'].values);

          errorsList.asMap().forEach((index, element) {
            String newLine = '';
            if (index < errorsList.length - 1) {
              newLine = '\n';
            }
            errorMessages += '${element[0]}$newLine';
          });
        } else if (body['exception'] != null) {
          body['message'] = 'Error';
          errorMessages = body['exception'];
        } else {
          body.forEach((key, value) {
            String newLine = '';
            if (body.length > 1) {
              newLine = '\n';
            }
            String error = value is String
                ? value
                : value is List
                    ? value[0]
                    : 'Error';
            errorMessages += '$error$newLine';
          });
        }

        PlatformAlertDialog(
          title: body['message'] ?? 'Error',
          content: errorMessages,
          actions: [
            PlatformAlertDialogAction(
              child: Text('OK'),
              isDefaultAction: true,
              onPressed: () => navigator?.pop(),
            )
          ],
        ).show();

        return null;
      }

      if (type == 'GET') {
        DefaultCacheManager().putFile(
            url, Uint8List.fromList(response.body.codeUnits),
            key: url);
      }
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
          msg: 'Could not connect to server. Please try again later.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.grey[700],
          textColor: Colors.white,
          fontSize: 14.0);

      if (type == 'GET') {
        FileInfo? cache = await DefaultCacheManager().getFileFromCache(url);
        if (cache != null) {
          body = jsonDecode(await rootBundle.loadString(cache.file.path));
        }
      }
    }

    return body;
  }

  Future<bool> checkServer(String apiUrl) async {
    Uri uri = Uri.parse('${apiUrl}ping');
    try {
      http.Response response = await http.get(uri);
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
