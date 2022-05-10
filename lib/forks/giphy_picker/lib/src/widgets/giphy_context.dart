import 'package:alterr/forks/giphy_picker/lib/src/model/client/gif.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/languages.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/rating.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_decorator.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_preview_types.dart';
import 'package:flutter/material.dart';

import '../../giphy_picker.dart';

/// Provides the context for a Giphy search operation, and makes its data available to its widget sub-tree.
class GiphyContext extends InheritedWidget {
  final String apiKey;
  final String? rating;
  final String? language;
  final bool? sticker;
  final ValueChanged<GiphyGif>? onSelected;
  final ErrorListener? onError;
  final bool? showPreviewPage;
  final GiphyDecorator? decorator;
  final String? searchText;
  final GiphyPreviewType? previewType;

  final Widget loadingIndicator;

  /// Debounce delay when searching
  final Duration searchDelay;

  const GiphyContext({
    Key? key,
    required Widget child,
    required this.apiKey,
    this.rating = GiphyRating.g,
    this.language = GiphyLanguage.english,
    this.sticker = false,
    this.onSelected,
    this.onError,
    this.showPreviewPage = true,
    this.searchText = 'Search Giphy',
    this.searchDelay = const Duration(milliseconds: 500),
    this.loadingIndicator = const CircularProgressIndicator(),
    @required this.decorator,
    this.previewType,
  }) : super(key: key, child: child);

  void select(GiphyGif gif) => onSelected?.call(gif);
  void error(dynamic error) => onError?.call(error);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static GiphyContext of(BuildContext context) {
    final settings = context
        .getElementForInheritedWidgetOfExactType<GiphyContext>()
        ?.widget as GiphyContext;

    return settings;
  }
}
