import 'package:flutter/widgets.dart';

class FancyBottomTabBarItem extends StatefulWidget {
  final Widget icon;
  final Widget? label;
  final bool selected;
  final Function()? onTap;
  final double topPadding;
  final int animationDurationMilliseconds;

  const FancyBottomTabBarItem({
    super.key,
    required this.icon,
    this.label,
    required this.selected,
    this.onTap,
    required this.topPadding,
    required this.animationDurationMilliseconds,
  });

  @override
  State<FancyBottomTabBarItem> createState() => _FancyBottomTabBarItemState();
}

class _FancyBottomTabBarItemState extends State<FancyBottomTabBarItem> {
  double _iconYPosition = 0;
  double _iconOpacity = 0;

  @override
  void initState() {
    super.initState();

    setSelected(widget.selected);
  }

  @override
  void didUpdateWidget(FancyBottomTabBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    setSelected(widget.selected);
  }

  void setSelected(bool selected) {
    setState(() {
      _iconYPosition = !widget.selected || widget.label == null ? 0 : -widget.topPadding;
      _iconOpacity = widget.selected ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: Padding(
          padding: widget.label != null ? EdgeInsets.only(top: widget.topPadding) : EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(opacity: 0, child: widget.icon),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: widget.animationDurationMilliseconds),
                    top: _iconYPosition,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: widget.animationDurationMilliseconds),
                      opacity: _iconOpacity,
                      child: widget.icon,
                    ),
                  ),
                ],
              ),
              if (widget.label != null) widget.label!,
            ],
          ),
        ),
      );
}
