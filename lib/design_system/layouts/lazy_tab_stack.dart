import 'package:flutter/material.dart';

/// Keeps visited tabs alive without mounting every feature at sign-in.
class LazyTabStack extends StatefulWidget {
  const LazyTabStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<LazyTabStack> {
  final Set<int> _visited = {};

  @override
  Widget build(BuildContext context) {
    _visited.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (index) {
        return _visited.contains(index)
            ? TickerMode(enabled: index == widget.index, child: widget.children[index])
            : const SizedBox.shrink();
      }),
    );
  }
}