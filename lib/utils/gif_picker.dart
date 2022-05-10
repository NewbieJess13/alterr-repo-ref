import 'package:alterr/forks/giphy_picker/lib/giphy_picker.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_client.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_decorator.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:flutter/material.dart';

class GifPicker {
  static Future<GiphyGif?> pick(BuildContext context) async {
    return await GiphyPicker.pickGif(
      context: context,
      apiKey: 'z8BVJZXb9IEin4jnM8mffoRCaqssXWS0',
      fullScreenDialog: true,
      showPreviewPage: false,
      loadingIndicator: PlatformSpinner(
        radius: 10,
        width: 20,
        height: 20,
      ),
      decorator: GiphyDecorator(
        showAppBar: false,
      ),
    );
  }
}
