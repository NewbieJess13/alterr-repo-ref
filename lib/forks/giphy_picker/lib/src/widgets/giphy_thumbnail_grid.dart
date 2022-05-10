import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_repository.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_context.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_preview_page.dart';
import 'package:alterr/forks/giphy_picker/lib/src/widgets/giphy_thumbnail.dart';
import 'package:flutter/material.dart';

/// A selectable grid view of gif thumbnails.
class GiphyThumbnailGrid extends StatelessWidget {
  final GiphyRepository repo;
  final ScrollController? scrollController;

  const GiphyThumbnailGrid(
      {Key? key, required this.repo, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        itemCount: repo.totalCount,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: GiphyThumbnail(key: Key('$index'), repo: repo, index: index),
            onTap: () async {
              // display preview page
              final giphy = GiphyContext.of(context);
              final gif = await repo.get(index);
              if (giphy.showPreviewPage!) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Theme(
                      data: giphy.decorator?.giphyTheme ?? Theme.of(context),
                      child: GiphyPreviewPage(
                        gif: gif,
                        onSelected: giphy.onSelected!,
                      ),
                    ),
                  ),
                );
              } else {
                giphy.onSelected?.call(gif);
              }
            }),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 2
                    : 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1));
  }
}
