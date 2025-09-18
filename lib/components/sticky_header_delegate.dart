// lib/components/sticky_header_delegate.dart

import 'package:flutter/material.dart';

/// Um delegate simples para usar com `SliverPersistentHeader`.
/// Mantém seu `child` fixo no topo com uma altura constante.
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;
  
  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    // Redesenha se o child ou a altura mudarem.
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}