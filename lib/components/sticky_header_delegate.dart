// lib/components/sticky_header_delegate.dart

import 'package:flutter/material.dart';

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double? height;

  StickyHeaderDelegate({required this.child, this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height!;
  
  @override
  double get minExtent => height!;

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) => true;
}