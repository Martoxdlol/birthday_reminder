import 'package:flutter/material.dart';

class BottomPopupRoute extends PageRoute {
  BottomPopupRoute({
    required this.builder,
    this.padding = 12.0,
    this.height = 400,
    this.showDragHandle = false,
  });

  final Widget Function(BuildContext context) builder;
  final double padding;
  final double height;
  final bool showDragHandle;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.black12;

  @override
  String? get barrierLabel => 'close';

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final mediaQueryData = MediaQuery.of(context);

    final left = mediaQueryData.viewInsets.left + padding;
    final right = mediaQueryData.viewInsets.right + padding;
    final bottom = mediaQueryData.viewInsets.bottom + padding;

    final maxHeight = mediaQueryData.size.height - bottom - mediaQueryData.padding.top - padding;

    double curatedHeight = height;

    double bottomOverflow = 0;

    if (curatedHeight > maxHeight) {
      curatedHeight = maxHeight;

      if (curatedHeight < 300) {
        bottomOverflow = 300 - curatedHeight - padding * 2;
        curatedHeight = 300;
      }
    }

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final p = details.delta.dy / curatedHeight;
        controller?.animateTo(animation.value - p, duration: Duration.zero);
      },
      onVerticalDragEnd: (details) {
        final dy = details.velocity.pixelsPerSecond.dy;

        double speed = 1.0;

        if (dy.abs() > 1000) {
          speed = 2.0;
        }
        if (dy.abs() > 2000) {
          speed = 3.0;
        }
        if (dy.abs() > 3000) {
          speed = 4.0;
        }

        double restoreAnimationDuration = (transitionDuration.inMilliseconds * (1.0 - animation.value));

        if (restoreAnimationDuration != 0) restoreAnimationDuration /= speed;

        if (dy > 0) {
          // controller?.animateBack(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          Navigator.of(context).pop();
        } else {
          controller?.animateTo(1, duration: Duration(milliseconds: restoreAnimationDuration.toInt()), curve: Curves.easeOut);
        }
      },
      child: SizedBox(
        height: mediaQueryData.size.height,
        width: mediaQueryData.size.width,
        child: Stack(
          children: [
            Positioned(
              left: left,
              right: right,
              bottom: bottom - bottomOverflow,
              height: curatedHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MediaQuery(
                  data: mediaQueryData.copyWith(viewInsets: const EdgeInsets.all(0), padding: mediaQueryData.padding.copyWith(top: 0)),
                  child: builder(context),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Transform.translate(
      offset: Offset(0, height * (1 - animation.value)),
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);
}
