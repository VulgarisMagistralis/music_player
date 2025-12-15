import 'package:flutter/material.dart';

class AnimatedOverflowText extends StatefulWidget {
  final String text;
  const AnimatedOverflowText({super.key, required this.text});

  @override
  State<AnimatedOverflowText> createState() => _AnimatedOverflowTextState();
}

///reload messes scroll
class _AnimatedOverflowTextState extends State<AnimatedOverflowText> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  void _startLoopScroll() {
    bool scrolling = false;
    const pauseDuration = Duration(seconds: 1);
    const scrollDuration = Duration(seconds: 4);

    /// Starts loop with chained play/pause animation.
    /// If dismounts, it will break animation so setting scroll to false
    while (mounted && _scrollController.hasClients && !scrolling) {
      scrolling = true;
      _scrollController
          .animateTo(_scrollController.position.maxScrollExtent, duration: scrollDuration, curve: Curves.linear)
          .then(
            (_) => Future.delayed(pauseDuration).then(
              (_) => _scrollController.animateTo(0, duration: scrollDuration, curve: Curves.linear).then((_) => _startLoopScroll(), onError: (_) => null),
              onError: (_) => null,
            ),
            onError: (_) => null,
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    clipBehavior: Clip.hardEdge,
    child: LayoutBuilder(
      builder: (_, constraints) {
        final String cleanedText = widget.text.trim();
        const TextStyle textStyle = TextStyle(fontSize: 20);
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: cleanedText, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final Text textWidget = Text(cleanedText, maxLines: 1, softWrap: false, textAlign: TextAlign.left, style: textStyle);
        final bool willOverflow = textPainter.width > constraints.maxWidth;
        if (willOverflow) WidgetsBinding.instance.addPostFrameCallback((_) => mounted && _scrollController.hasClients ? _startLoopScroll() : null);
        return Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
          child: willOverflow
              ? SingleChildScrollView(scrollDirection: Axis.horizontal, controller: _scrollController, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, child: textWidget)
              : textWidget,
        );
      },
    ),
  );
}
