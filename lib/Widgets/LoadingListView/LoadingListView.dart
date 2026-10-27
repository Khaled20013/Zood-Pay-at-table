import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

import 'LoadingListController.dart';

typedef LoadMore = Future Function();

typedef OnLoadMore = void Function();

typedef ItemCount = int Function();

typedef HasMore = bool Function();

// typedef OnLoadMoreFinished = void Function();

typedef OnRefresh = Future<void> Function();

/// A list view that can be used for incrementally loading items when the user scrolls.
/// This is an extension of the ListView widget that uses the ListView.builder constructor.
class LoadingListView extends StatefulWidget {
  /// A callback that indicates if the collection associated with the ListView has more items that should be loaded
  final HasMore hasMore;

  /// A callback to an asynchronous function that would load more items
  final LoadMore loadMore;

  /// Determines when the list view should attempt to load more items based on of the index of the item is scrolling into view
  /// This is relative to the bottom of the list and has a default value of 0 so that it loads when the last item within the list view scrolls into view.
  /// As an example, setting this to 1 would attempt to load more items when the second last item within the list view scrolls into view
  final int loadMoreOffsetFromBottom;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final ItemCount itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double? cacheExtent;
  final int pageSize;
  final int shimerCount = 10;
  final Widget? shimerWidget;
  final int numCellsOnRow;
  final bool? disapleScroll;

  /// The number of children in the cross axis.
  final int? crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double? mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double? crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double? childAspectRatio;

  /// The extent of each tile in the main axis. If provided it would define the
  /// logical pixels taken by each tile in the main-axis.
  ///
  /// If null, [childAspectRatio] is used instead.
  final double? mainAxisExtent;

  /// A callback that is triggered when more items are being loaded
  final OnLoadMore? onLoadMore;

  /// A callback that is triggered when items have finished being loaded
  // final OnLoadMoreFinished? onLoadMoreFinished;
  final OnRefresh? onRefresh;

  final LoadingListController controller;

  const LoadingListView(
      {super.key,
      required this.hasMore,
      required this.loadMore,
      this.loadMoreOffsetFromBottom = 0,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.scrollController,
      this.primary,
      this.physics,
      this.shrinkWrap = false,
      this.padding,
      this.itemExtent,
      required this.itemBuilder,
      required this.itemCount,
      this.separatorBuilder,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.cacheExtent,
      this.onLoadMore,
      // this.onLoadMoreFinished,
      required this.controller,
      this.disapleScroll,
      this.onRefresh,
      this.pageSize = 10,
      this.shimerWidget,
      this.numCellsOnRow = 1,
      this.crossAxisCount,
      this.mainAxisSpacing,
      this.crossAxisSpacing,
      this.childAspectRatio,
      this.mainAxisExtent});

  @override
  LoadingListViewState createState() {
    return LoadingListViewState();
  }
}

class LoadingListViewState extends State<LoadingListView> {
  bool _loadingMore = false;
  final PublishSubject<bool> _loadingMoreSubject = PublishSubject<bool>();
  Stream<bool>? _loadingMoreStream;

  LoadingListViewState() {
    _loadingMoreStream =
        _loadingMoreSubject.switchMap((shouldLoadMore) => loadMore());
  }

  bool get _isSeparated => widget.separatorBuilder != null;

  int _separatedItemCount() {
    final count = widget.itemCount();
    if (count == 0) {
      return 0;
    }
    return count * 2 - 1;
  }

  Widget _separatedItemBuilder(BuildContext context, int index) {
    final itemIndex = index ~/ 2;

    if (index.isOdd) {
      return widget.separatorBuilder!(context, itemIndex);
    } else {
      return _buildItem(context, itemIndex);
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    if (!_loadingMore &&
        index == widget.itemCount() - widget.loadMoreOffsetFromBottom - 1 &&
        widget.hasMore() &&
        widget.itemCount() >= widget.pageSize) {
      _loadingMore = true;
      _loadingMoreSubject.add(true);
    }

    return widget.itemBuilder(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
        },
        child: StreamBuilder(
            stream: _loadingMoreStream,
            builder: (context, snapshot) {
              final itemCount =
                  _isSeparated ? _separatedItemCount() : widget.itemCount();

              return (widget.controller.loading && itemCount == 0)
                  ? shimmerData()
                  : realData(itemCount);
            }));
  }

  Widget shimmerData() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: widget.shimerCount, // Adjust the count based on your needs
        itemBuilder: (context, index) {
          return ListTile(
            title: widget.shimerWidget ??
                Container(
                  height: 20,
                  width: 200,
                  color: Colors.white,
                ),
          );
        },
      ),
    );
  }

  Widget realData(int itemCount) {
    final itemBuilder = _isSeparated ? _separatedItemBuilder : _buildItem;

    return widget.numCellsOnRow == 1
        ? listViewOneCellRow(itemBuilder: itemBuilder, itemCount: itemCount)
        : listViewMoreCellRow(itemBuilder: itemBuilder, itemCount: itemCount);
  }

  Widget listViewMoreCellRow(
      {required NullableIndexedWidgetBuilder itemBuilder,
      required int itemCount}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            widget.crossAxisCount ?? widget.numCellsOnRow, // Two items per row
        crossAxisSpacing: widget.crossAxisSpacing ?? 0,
        mainAxisSpacing: widget.mainAxisSpacing ?? 0,
        childAspectRatio:
            widget.childAspectRatio ?? 1, // Width-to-height ratio of items
        mainAxisExtent: widget.mainAxisExtent,
      ),
      key: widget.key,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      scrollCacheExtent: widget.cacheExtent == null
          ? null
          : ScrollCacheExtent.pixels(widget.cacheExtent!),
    );
  }

  Widget listViewOneCellRow(
      {required NullableIndexedWidgetBuilder itemBuilder,
      required int itemCount}) {
    return ListView.builder(
      key: widget.key,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.disapleScroll == true
          ? const NeverScrollableScrollPhysics()
          : widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      scrollCacheExtent: widget.cacheExtent == null
          ? null
          : ScrollCacheExtent.pixels(widget.cacheExtent!),
    );
  }

  Stream<bool> loadMore() async* {
    yield _loadingMore;
    if (widget.onLoadMore != null) {
      // widget.controller.loading = true;
      widget.onLoadMore!();
      await widget.loadMore();
    }
    _loadingMore = false;
    yield _loadingMore;
  }

  @override
  void dispose() {
    _loadingMoreSubject.close();
    super.dispose();
  }
}
