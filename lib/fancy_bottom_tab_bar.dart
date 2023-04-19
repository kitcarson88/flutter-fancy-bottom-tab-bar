library fancy_bottom_tab_bar;

import 'dart:ui' as ui;

import 'package:fancy_bottom_tab_bar/extensions/build_context.dart';
import 'package:fancy_bottom_tab_bar/fancy_bottom_tab_bar_item.dart';
import 'package:flutter/material.dart';

class FancyBottomTabBar extends StatefulWidget {
  final List<Widget> icons;
  final List<Widget>? activeIcons;
  final List<Widget>? labels;
  final List<Widget>? darkIcons;
  final List<Widget>? darkActiveIcons;
  final List<Widget>? darkLabels;
  final int initialSelectedIndex;
  final Function(int)? onItemTap;
  final double? height;
  final Color? backgroundColor;
  final Color? darkBackgroundColor;
  final Gradient? backgroundGradient;
  final Gradient? darkBackgroundGradient;
  final List<BoxShadow>? boxShadows;
  final BorderRadiusGeometry? borderRadius;
  final double topPadding;
  final double cursorSize;
  final double cursorLedge;
  final Color cursorColor;
  final Color? darkCursorColor;
  final List<Color>? cursorColors;
  final List<Color>? darkCursorColors;
  final Widget? wave;
  final Widget? darkWave;
  final double wavePositioning;
  final Widget? wavePositioningOverride;
  final Widget? darkWavePositioningOverride;
  final int animationMilliseconds;

  const FancyBottomTabBar({
    Key? key,
    required this.initialSelectedIndex,
    required this.onItemTap,
    this.backgroundColor,
    this.darkBackgroundColor,
    this.backgroundGradient,
    this.darkBackgroundGradient,
    this.boxShadows,
    this.borderRadius,
    this.topPadding = 0,
    required this.icons,
    this.activeIcons,
    this.labels,
    this.darkIcons,
    this.darkActiveIcons,
    this.darkLabels,
    this.height,
    this.animationMilliseconds = 200,
    this.cursorSize = 60.0,
    this.cursorLedge = 0,
    this.cursorColor = Colors.transparent,
    this.darkCursorColor,
    this.cursorColors,
    this.darkCursorColors,
    this.wave,
    this.darkWave,
    this.wavePositioning = 0,
    this.wavePositioningOverride,
    this.darkWavePositioningOverride,
  })  : assert(cursorLedge <= cursorSize),
        assert(wavePositioning >= 0),
        super(key: key);

  @override
  State<FancyBottomTabBar> createState() => _FancyBottomTabBarState();
}

class _FancyBottomTabBarState extends State<FancyBottomTabBar> with TickerProviderStateMixin {
  int _currentSelectedIndex = 0;

  AnimationController? _animationController;
  Tween<double>? _positionTween;
  Animation<double>? _positionAnimation;

  AnimationController? _fadeController;
  Animation<double>? _cursorIconFadeOutAnimation;

  AnimationController? _colorController;
  ColorTween? _cursorColorTween;
  Animation? _cursorColorAnimation;

  double _cursorIconAlpha = 1;
  Widget? _activeIcon;
  Widget? _nextIcon;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.animationMilliseconds));
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.animationMilliseconds));
    _colorController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.animationMilliseconds));

    _positionTween = Tween<double>(begin: -1, end: -1);
    _positionAnimation = _positionTween
        ?.animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOut))
      ?..addListener(() {
        setState(() {});
      });

    _cursorIconFadeOutAnimation = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          _cursorIconAlpha = _cursorIconFadeOutAnimation!.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _activeIcon = _nextIcon;
            _cursorIconAlpha = 1;
          });
        }
      });

    _cursorColorTween = ColorTween(begin: Colors.white, end: Colors.black);
    _cursorColorAnimation = _cursorColorTween
        ?.animate(CurvedAnimation(parent: _colorController!, curve: Curves.easeOut))
      ?..addListener(() {
        setState(() {});
      });

    _currentSelectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialization here to use context after its initialization
    if (context.isDarkMode() &&
        widget.darkActiveIcons != null &&
        widget.darkActiveIcons!.isNotEmpty) {
      _activeIcon = _nextIcon = widget.darkActiveIcons![_currentSelectedIndex];
    } else if (widget.activeIcons != null && widget.activeIcons!.isNotEmpty) {
      _activeIcon = _nextIcon = widget.activeIcons![_currentSelectedIndex];
    } else {
      _activeIcon = _nextIcon = widget.icons[_currentSelectedIndex];
    }
  }

  // double? currentPosition;
  // if (_positionAnimation?.value != null) {
  //   if (context.isRtl()) {
  //     currentPosition = 1 - _positionAnimation!.value;
  //   } else {
  //     currentPosition = _positionAnimation!.value;
  //   }
  // }
  @override
  Widget build(BuildContext context) => Container(
        color: context.isDarkMode() ? widget.darkBackgroundColor : widget.backgroundColor,
        decoration: widget.backgroundColor == null &&
                (widget.backgroundGradient != null ||
                    widget.borderRadius != null ||
                    widget.boxShadows != null)
            ? BoxDecoration(
                gradient: context.isDarkMode() && widget.darkBackgroundGradient != null
                    ? widget.darkBackgroundGradient
                    : widget.backgroundGradient,
                borderRadius: widget.borderRadius,
                boxShadow: widget.boxShadows,
              )
            : null,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: _bottomPadding(context)),
              child: SizedBox(
                height: widget.height,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (var i = 0; i < widget.icons.length; ++i)
                      Expanded(
                        child: FancyBottomTabBarItem(
                          icon: context.isDarkMode() &&
                                  widget.darkIcons != null &&
                                  widget.darkIcons!.length > i
                              ? widget.darkIcons![i]
                              : widget.icons[i],
                          label: context.isDarkMode() &&
                                  widget.darkLabels != null &&
                                  widget.darkLabels!.length > i
                              ? widget.darkLabels![i]
                              : widget.labels?[i],
                          selected: _currentSelectedIndex == i,
                          onTap: () {
                            var currentColor = _currentCursorColor(context);
                            _updateIndexTabData(i);
                            var nextColor = _currentCursorColor(context);

                            final positionTo = context.isRtl()
                                ? -_convertToZeroRadialValue(i)
                                : _convertToZeroRadialValue(i);

                            _initAnimationAndStart(_positionAnimation?.value ?? 0, positionTo,
                                currentColor, nextColor);

                            if (widget.onItemTap != null) {
                              widget.onItemTap!(i);
                            }
                          },
                          width: MediaQuery.of(context).size.width / widget.icons.length,
                          topPadding: widget.topPadding,
                          animationDurationMilliseconds: widget.animationMilliseconds,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                heightFactor: (widget.cursorLedge / widget.cursorSize) * 2,
                alignment: Alignment(_positionAnimation?.value ?? -1, 1),
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.icons.length,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.wavePositioningOverride != null)
                        context.isDarkMode() && widget.darkWavePositioningOverride != null
                            ? widget.darkWavePositioningOverride!
                            : widget.wavePositioningOverride!,
                      if (widget.wavePositioningOverride == null && widget.wave != null)
                        Positioned(
                          top: -widget.wavePositioning,
                          child: context.isDarkMode() && widget.darkWave != null
                              ? widget.darkWave!
                              : widget.wave!,
                        ),
                      SizedBox(
                        width: widget.cursorSize,
                        height: widget.cursorSize,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentCursorColor(context),
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                Opacity(
                                  opacity: _cursorIconAlpha,
                                  child: _activeIcon,
                                ),
                                Opacity(
                                  opacity: 1 - _cursorIconAlpha,
                                  child: _nextIcon,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _updateIndexTabData(int index) {
    setState(() {
      _currentSelectedIndex = index;

      if (context.isDarkMode() &&
          widget.darkActiveIcons != null &&
          widget.darkActiveIcons!.length > index) {
        _nextIcon = widget.darkActiveIcons![index];
      } else if (widget.activeIcons != null && widget.activeIcons!.length > index) {
        _nextIcon = widget.activeIcons![index];
      } else {
        _nextIcon = widget.icons[index];
      }
    });
  }

  void _initAnimationAndStart(double positionFrom, double positionTo,
      [Color? colorFrom, Color? colorTo]) {
    _positionTween?.begin = positionFrom;
    _positionTween?.end = positionTo;

    if (colorFrom != null && colorTo != null) {
      _cursorColorTween?.begin = colorFrom;
      _cursorColorTween?.end = colorTo;

      _colorController?.reset();
      _colorController?.forward();
    }

    _animationController?.reset();
    _fadeController?.reset();
    _animationController?.forward();
    _fadeController?.forward();
  }

  double _convertToZeroRadialValue(int index) {
    var normalizedLength = (widget.icons.length - 1).toDouble() / 2;
    return (index.toDouble() - normalizedLength) / normalizedLength;
  }

  Color _currentCursorColor(BuildContext context) {
    if (context.isDarkMode() &&
        widget.darkCursorColors != null &&
        widget.darkCursorColors!.length == widget.icons.length) {
      if (_cursorColorAnimation != null &&
          (_cursorColorAnimation!.isCompleted || _cursorColorAnimation!.isDismissed)) {
        return widget.darkCursorColors![_currentSelectedIndex];
      } else {
        return _cursorColorAnimation?.value ?? Colors.white;
      }
    } else if (widget.cursorColors != null && widget.cursorColors!.length == widget.icons.length) {
      if (_cursorColorAnimation != null &&
          (_cursorColorAnimation!.isCompleted || _cursorColorAnimation!.isDismissed)) {
        return widget.cursorColors![_currentSelectedIndex];
      } else {
        return _cursorColorAnimation?.value ?? Colors.white;
      }
    } else if (context.isDarkMode() && widget.darkCursorColor != null) {
      return widget.darkCursorColor!;
    } else {
      return widget.cursorColor;
    }
  }

  double _bottomPadding(BuildContext context) {
    var bottomSafeAreaPadding = MediaQueryData.fromWindow(ui.window).padding.bottom;
    return bottomSafeAreaPadding > 0 ? bottomSafeAreaPadding : 20.0;
  }
}
