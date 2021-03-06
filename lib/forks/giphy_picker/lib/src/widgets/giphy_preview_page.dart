import 'package:alterr/forks/giphy_picker/lib/src/model/client/gif.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_image.dart';
import 'package:flutter/material.dart';

/// Presents a Giphy preview image.
class GiphyPreviewPage extends StatelessWidget {
  final GiphyGif gif;
  final Widget? title;
  final ValueChanged<GiphyGif> onSelected;

  const GiphyPreviewPage(
      {required this.gif, required this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(title: title, actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check), onPressed: () => onSelected.call(gif))
        ]),
        body: SafeArea(
            child: Center(
                child: GiphyImage.original(
              gif: gif,
              width: media.orientation == Orientation.portrait
                  ? double.maxFinite
                  : null,
              height: media.orientation == Orientation.landscape
                  ? double.maxFinite
                  : null,
              fit: BoxFit.contain,
            )),
            bottom: false));
  }
}
