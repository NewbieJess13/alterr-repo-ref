library giphy_picker;

import 'dart:async';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/gif.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/languages.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/rating.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_decorator.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_preview_types.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_context.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_search_page.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

typedef ErrorListener = void Function(dynamic error);

/// Provides Giphy picker functionality.
class GiphyPicker {
  /// Renders a full screen modal dialog for searching, and selecting a Giphy image.
  static Future<GiphyGif?> pickGif({
    required BuildContext context,
    required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    bool sticker = false,
    Widget? title,
    ErrorListener? onError,
    bool showPreviewPage = true,
    GiphyDecorator? decorator,
    bool fullScreenDialog = true,
    String searchText = 'Search GIPHY',
    Widget loadingIndicator = const CircularProgressIndicator(),
    GiphyPreviewType? previewType,
  }) async {
    GiphyGif? result;
    final _decorator = decorator ?? GiphyDecorator();
    await PlatformBottomsheetModal(
        context: context,
        child: GiphyContext(
          decorator: _decorator,
          previewType: previewType ?? GiphyPreviewType.previewGif,
          child: GiphySearchPage(
            title: title,
          ),
          apiKey: apiKey,
          rating: rating,
          language: lang,
          sticker: sticker,
          onError: onError ?? (error) => _showErrorDialog(context, error),
          loadingIndicator: loadingIndicator,
          onSelected: (gif) {
            result = gif;
            navigator?.pop();
          },
          showPreviewPage: showPreviewPage,
          searchText: searchText,
        )).show();
    return result;
  }

  static void _showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Giphy error'),
          content: Text('An error occurred. $error'),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
