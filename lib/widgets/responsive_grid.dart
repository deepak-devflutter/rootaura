import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/utils/responsive.dart';

/// A column-count grid where every card in a row is the SAME width and the
/// SAME height. Unlike [Wrap], rows use [IntrinsicHeight] + stretched
/// [Expanded] cells, so mismatched text length never produces ragged boxes.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobile;
  final int tablet;
  final int desktop;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobile = 1,
    this.tablet = 2,
    this.desktop = 3,
    this.spacing = AppDimens.lg,
    this.runSpacing = AppDimens.lg,
  });

  @override
  Widget build(BuildContext context) {
    final columns =
        Responsive.value<int>(context, mobile: mobile, tablet: tablet, desktop: desktop);

    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final end = (start + columns).clamp(0, children.length);
      final rowItems = children.sublist(start, end);

      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) cells.add(SizedBox(width: spacing));
        cells.add(
          Expanded(
            child: c < rowItems.length ? rowItems[c] : const SizedBox.shrink(),
          ),
        );
      }

      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ));
      if (end < children.length) rows.add(SizedBox(height: runSpacing));
    }

    return Column(children: rows);
  }
}
