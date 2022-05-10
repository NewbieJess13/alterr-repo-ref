import 'dart:async';
import 'package:alterr/forks/giphy_picker/lib/src/model/giphy_repository.dart';
import 'package:alterr/forks/giphy_picker/lib/src/utils/debouncer.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'giphy_context.dart';
import 'giphy_thumbnail_grid.dart';
import 'package:get/get.dart';

/// Provides the UI for searching Giphy gif images.
class GiphySearchView extends StatefulWidget {
  @override
  _GiphySearchViewState createState() => _GiphySearchViewState();
}

class _GiphySearchViewState extends State<GiphySearchView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repoController = StreamController<GiphyRepository>();
  late Debouncer _debouncer;

  @override
  void initState() {
    // initiate search on next frame (we need context)
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final giphy = GiphyContext.of(context);
      _debouncer = Debouncer(
        delay: giphy.searchDelay,
      );
      _search(giphy);
    });
    super.initState();
  }

  @override
  void dispose() {
    _repoController.close();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giphy = GiphyContext.of(context);
    final giphyDecorator = giphy.decorator;

    final inputDecoration = InputDecoration(
      hintText: giphy.searchText,
    );
    if (giphyDecorator!.giphyTheme != null) {
      inputDecoration
          .applyDefaults(giphyDecorator.giphyTheme!.inputDecorationTheme);
    }

    return Scaffold(
      body: Column(children: [
        Container(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: CustomTextField(
                    controller: _textController,
                    title: 'Search GIPHY',
                    onChanged: (value) => _delayedSearch(giphy, value),
                  ),
                ),
              ),
              InkWell(
                onTap: () => navigator?.pop(),
                child: Text(
                  'Done',
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: StreamBuilder(
                stream: _repoController.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<GiphyRepository> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.totalCount > 0
                        ? NotificationListener(
                            child: RefreshIndicator(
                                child: GiphyThumbnailGrid(
                                    key: Key('${snapshot.data.hashCode}'),
                                    repo: snapshot.data!,
                                    scrollController: _scrollController),
                                onRefresh: () =>
                                    _search(giphy, term: _textController.text)),
                            onNotification: (n) {
                              // hide keyboard when scrolling
                              if (n is UserScrollNotification) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                return true;
                              }
                              return false;
                            },
                          )
                        : Center(child: Text('No results'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('An error occurred'));
                  }
                  return Center(child: giphy.loadingIndicator);
                }))
      ]),
    );
  }

  void _delayedSearch(GiphyContext giphy, String term) =>
      _debouncer.call(() => _search(giphy, term: term));

  Future _search(GiphyContext giphy, {String term = ''}) async {
    // skip search if term does not match current search text
    if (term != _textController.text) {
      return;
    }

    try {
      // search, or trending when term is empty
      final repo = await (term.isEmpty
          ? GiphyRepository.trending(
              apiKey: giphy.apiKey,
              rating: giphy.rating!,
              sticker: giphy.sticker!,
              previewType: giphy.previewType,
              onError: giphy.onError)
          : GiphyRepository.search(
              apiKey: giphy.apiKey,
              query: term,
              rating: giphy.rating!,
              lang: giphy.language!,
              sticker: giphy.sticker!,
              previewType: giphy.previewType,
              onError: giphy.onError,
            ));

      // scroll up
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      if (mounted) {
        _repoController.add(repo);
      }
    } catch (error) {
      if (mounted) {
        _repoController.addError(error);
      }
      giphy.onError?.call(error);
    }
  }
}
