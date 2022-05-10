import 'dart:convert';
import 'dart:developer';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/services/localstorage.dart';
import 'package:pusher_client/pusher_client.dart';

class Pusher {
  static init() async {
    PusherClient pusher;
    Map<String, dynamic> config;
    String? apiKeys = await LocalStorage.getKeysSharedPref();
    if (apiKeys == null) return null;

    Map<String, dynamic> pusherMap = jsonDecode(apiKeys)['pusher'];
    String token = await Helpers.getToken();
    config = await Helpers.getConfig();
    pusher = PusherClient(
        pusherMap['key'],
        PusherOptions(
          cluster: pusherMap['cluster'],
          encrypted: false,
          auth: PusherAuth(
            config['pusher_url'],
            headers: {'Authorization': 'Bearer $token'},
          ),
        ),
        enableLogging: true,
        autoConnect: true);

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state?.previousState}, currentState: ${state?.currentState}");
    });
    pusher.onConnectionError((error) {
      log("error: ${error?.message}");
    });

    return pusher;
  }
}
