library fancy_bottom_tab_bar;

import 'package:fancy_bottom_tab_bar/extensions/build_context.dart';
import 'package:fancy_bottom_tab_bar/fancy_bottom_tab_bar_controller.dart';
import 'package:fancy_bottom_tab_bar/fancy_bottom_tab_bar_item.dart';
import 'package:flutter/material.dart';

class FancyBottomTabBar extends StatefulWidget {
  final int initialSelectedIndex;
  final Function(int)? onItemTap;
  final FancyBottomTabBarController? controller;
  final List<Widget> icons;
  final List<Widget>? activeIcons;
  final List<Widget>? darkIcons;
  final List<Widget>? darkActiveIcons;
  final List<Widget>? collapsedIcons;
  final List<Widget>? collapsedActiveIcons;
  final List<Widget>? collapsedDarkIcons;
  final List<Widget>? collapsedDarkActiveIcons;
  final List<Widget>? labels;
  final List<Widget>? darkLabels;
  final double? height;
  final double collapsedMargin;
  final double topPadding;
  final Color? backgroundColor;
  final Color? darkBackgroundColor;
  final Gradient? backgroundGradient;
  final Gradient? darkBackgroundGradient;
  final List<BoxShadow>? boxShadows;
  final BorderRadiusGeometry? borderRadius;
  final double cursorSize;
  final double cursorLedge;
  final double collapsedCursorLedge;
  final Color cursorColor;
  final Color? darkCursorColor;
  final Color? collapsedCursorColor;
  final Color? collapsedDarkCursorColor;
  final List<Color>? cursorColors;
  final List<Color>? darkCursorColors;
  final List<Color>? collapsedCursorColors;
  final List<Color>? collapsedDarkCursorColors;
  final Widget? wave;
  final Widget? darkWave;
  final double wavePositioning;
  final Widget? wavePositioningOverride;
  final Widget? darkWavePositioningOverride;
  final int animationMilliseconds;

  // ignore: use_super_parameters
  const FancyBottomTabBar({
    Key? key,
    required this.initialSelectedIndex,
    required this.onItemTap,
    this.controller,
    this.height,
    this.collapsedMargin = 20,
    this.topPadding = 0,
    this.backgroundColor,
    this.darkBackgroundColor,
    this.backgroundGradient,
    this.darkBackgroundGradient,
    this.boxShadows,
    this.borderRadius,
    required this.icons,
    this.activeIcons,
    this.darkIcons,
    this.darkActiveIcons,
    this.collapsedIcons,
    this.collapsedActiveIcons,
    this.collapsedDarkIcons,
    this.collapsedDarkActiveIcons,
    this.labels,
    this.darkLabels,
    this.cursorSize = 60.0,
    this.cursorLedge = 0,
    this.collapsedCursorLedge = 0,
    this.cursorColor = Colors.transparent,
    this.darkCursorColor,
    this.collapsedCursorColor,
    this.collapsedDarkCursorColor,
    this.cursorColors,
    this.darkCursorColors,
    this.collapsedCursorColors,
    this.collapsedDarkCursorColors,
    this.wave,
    this.darkWave,
    this.wavePositioning = 0,
    this.wavePositioningOverride,
    this.darkWavePositioningOverride,
    this.animationMilliseconds = 100,
  })  : assert(cursorLedge <= cursorSize),
        assert(wavePositioning >= 0),
        super(key: key);

  @override
  State<FancyBottomTabBar> createState() => _FancyBottomTabBarState();
}

class _FancyBottomTabBarState extends State<FancyBottomTabBar> with TickerProviderStateMixin {
  int _currentSelectedIndex = 0;

  bool _expanded = false;

  AnimationController? _animationController;
  Tween<double>? _positionTween;
  Animation<double>? _positionAnimation;

  AnimationController? _fadeController;
  Animation<double>? _cursorIconFadeOutAnimation;

  AnimationController? _colorController;
  ColorTween? _cursorColorTween;
  Animation? _cursorColorAnimation;

  double _cursorIconAlpha = 1;
  double _cursorLedge = 0;
  Widget? _activeIcon;
  Widget? _nextIcon;

  @override
  void initState() {
    super.initState();

    var animationDuration = Duration(milliseconds: widget.animationMilliseconds);

    _animationController = AnimationController(vsync: this, duration: animationDuration);
    _fadeController = AnimationController(vsync: this, duration: animationDuration);
    _colorController = AnimationController(vsync: this, duration: animationDuration);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expanded = widget.controller?.value ?? true;
      widget.controller?.addListener(_expandShrink);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _expanded = widget.controller?.value ?? true;

    // Initialization here to use context after its initialization
    if (_expanded) {
      if (context.isDarkMode() &&
          widget.darkActiveIcons != null &&
          widget.darkActiveIcons!.isNotEmpty) {
        _activeIcon = _nextIcon = widget.darkActiveIcons![_currentSelectedIndex];
      } else if (widget.activeIcons != null && widget.activeIcons!.isNotEmpty) {
        _activeIcon = _nextIcon = widget.activeIcons![_currentSelectedIndex];
      } else {
        _activeIcon = _nextIcon = widget.icons[_currentSelectedIndex];
      }
    } else {
      if (context.isDarkMode() &&
          widget.collapsedDarkActiveIcons != null &&
          widget.collapsedDarkActiveIcons!.isNotEmpty) {
        _activeIcon = _nextIcon = widget.collapsedDarkActiveIcons![_currentSelectedIndex];
      } else if (widget.activeIcons != null && widget.activeIcons!.isNotEmpty) {
        _activeIcon = _nextIcon = widget.collapsedActiveIcons![_currentSelectedIndex];
      } else if (widget.collapsedIcons != null && widget.collapsedIcons!.isNotEmpty) {
        _activeIcon = _nextIcon = widget.collapsedIcons![_currentSelectedIndex];
      }
    }

    _cursorLedge = _expanded ? widget.cursorLedge : widget.collapsedCursorLedge;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_expandShrink);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bckgrdColor = context.isDarkMode() ? widget.darkBackgroundColor : widget.backgroundColor;
    var animationDuration = Duration(milliseconds: widget.animationMilliseconds);
    var bckgrdDecoration = widget.backgroundColor == null &&
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
        : null;

    Widget? waveWidget;

    if (widget.wavePositioningOverride != null) {
      waveWidget = context.isDarkMode() && widget.darkWavePositioningOverride != null
          ? widget.darkWavePositioningOverride!
          : widget.wavePositioningOverride!;

      waveWidget = AnimatedOpacity(
        duration: animationDuration,
        opacity: _expanded ? 1.0 : 0.0,
        child: waveWidget,
      );
    }

    if (widget.wavePositioningOverride == null && widget.wave != null) {
      waveWidget =
          context.isDarkMode() && widget.darkWave != null ? widget.darkWave! : widget.wave!;

      waveWidget = Positioned(
        top: -widget.wavePositioning,
        child: AnimatedOpacity(
          duration: animationDuration,
          opacity: _expanded ? 1.0 : 0.0,
          child: waveWidget,
        ),
      );
    }

    return AnimatedContainer(
      duration: animationDuration,
      color: bckgrdColor,
      decoration: bckgrdDecoration,
      margin: EdgeInsets.only(
        left: _expanded ? 0 : widget.collapsedMargin,
        right: _expanded ? 0 : widget.collapsedMargin,
        bottom: _expanded ? 0 : _bottomPadding(context),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: animationDuration,
            height: widget.height,
            margin: _expanded ? EdgeInsets.only(bottom: _bottomPadding(context)) : EdgeInsets.zero,
            child: Row(
              children: [
                for (var i = 0; i < widget.icons.length; ++i)
                  Expanded(
                      child: FancyBottomTabBarItem(
                    icon: context.isDarkMode() &&
                            widget.darkIcons != null &&
                            widget.darkIcons!.length > i
                        ? widget.darkIcons![i]
                        : widget.icons[i],
                    label: _expanded
                        ? (context.isDarkMode() &&
                                widget.darkLabels != null &&
                                widget.darkLabels!.length > i
                            ? widget.darkLabels![i]
                            : widget.labels?[i])
                        : null,
                    selected: _currentSelectedIndex == i,
                    onTap: () {
                      var currentColor = _currentCursorColor(context);
                      _updateIndexTabData(i);
                      var nextColor = _currentCursorColor(context);

                      final positionTo = context.isRtl()
                          ? -_convertToZeroRadialValue(i)
                          : _convertToZeroRadialValue(i);

                      _initAnimationAndStart(
                          _positionAnimation?.value ?? 0, positionTo, currentColor, nextColor);

                      if (widget.onItemTap != null) {
                        widget.onItemTap!(i);
                      }
                    },
                    topPadding: widget.topPadding,
                    animationDurationMilliseconds: widget.animationMilliseconds,
                  )),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedAlign(
              duration: animationDuration,
              heightFactor: (_cursorLedge / widget.cursorSize) * 2,
              alignment: Alignment(_positionAnimation?.value ?? -1, 1),
              child: FractionallySizedBox(
                widthFactor: 1 / widget.icons.length,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    if (waveWidget != null) waveWidget,
                    SizedBox(
                      width: widget.cursorSize,
                      height: widget.cursorSize,
                      child: AnimatedContainer(
                        duration: animationDuration,
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
          )
        ],
      ),
    );
  }

  void _updateIndexTabData(int index) {
    setState(() {
      _currentSelectedIndex = index;

      if (_expanded) {
        if (context.isDarkMode() &&
            widget.darkActiveIcons != null &&
            widget.darkActiveIcons!.length > index) {
          _nextIcon = widget.darkActiveIcons![index];
        } else if (widget.activeIcons != null && widget.activeIcons!.length > index) {
          _nextIcon = widget.activeIcons![index];
        } else {
          _nextIcon = widget.icons[index];
        }
      } else {
        if (context.isDarkMode() &&
            widget.collapsedDarkActiveIcons != null &&
            widget.collapsedDarkActiveIcons!.length > index) {
          _nextIcon = widget.collapsedDarkActiveIcons![index];
        } else if (widget.collapsedActiveIcons != null &&
            widget.collapsedActiveIcons!.length > index) {
          _nextIcon = widget.collapsedActiveIcons![index];
        } else if (widget.collapsedIcons != null && widget.collapsedIcons!.isNotEmpty) {
          _nextIcon = widget.collapsedIcons![index];
        }
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

  Color _currentCursorColor(BuildContext context) {
    if (_expanded) {
      if (context.isDarkMode() &&
          widget.darkCursorColors != null &&
          widget.darkCursorColors!.length == widget.icons.length) {
        if (_cursorColorAnimation != null &&
            (_cursorColorAnimation!.isCompleted || _cursorColorAnimation!.isDismissed)) {
          return widget.darkCursorColors![_currentSelectedIndex];
        } else {
          return _cursorColorAnimation?.value ?? Colors.white;
        }
      } else if (widget.cursorColors != null &&
          widget.cursorColors!.length == widget.icons.length) {
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
    } else {
      if (context.isDarkMode() &&
          widget.collapsedDarkCursorColors != null &&
          widget.collapsedDarkCursorColors!.length == widget.icons.length) {
        if (_cursorColorAnimation != null &&
            (_cursorColorAnimation!.isCompleted || _cursorColorAnimation!.isDismissed)) {
          return widget.collapsedDarkCursorColors![_currentSelectedIndex];
        } else {
          return _cursorColorAnimation?.value ?? Colors.white;
        }
      } else if (widget.collapsedCursorColors != null &&
          widget.collapsedCursorColors!.length == widget.icons.length) {
        if (_cursorColorAnimation != null &&
            (_cursorColorAnimation!.isCompleted || _cursorColorAnimation!.isDismissed)) {
          return widget.collapsedCursorColors![_currentSelectedIndex];
        } else {
          return _cursorColorAnimation?.value ?? Colors.white;
        }
      } else if (context.isDarkMode() && widget.darkCursorColor != null) {
        return widget.collapsedDarkCursorColor!;
      } else if (widget.collapsedCursorColor != null) {
        return widget.collapsedCursorColor!;
      } else {
        return widget.cursorColor;
      }
    }
  }

  double _convertToZeroRadialValue(int index) {
    var normalizedLength = (widget.icons.length - 1).toDouble() / 2;
    return (index.toDouble() - normalizedLength) / normalizedLength;
  }

  double _bottomPadding(BuildContext context) {
    var bottomSafeAreaPadding = MediaQuery.of(context).padding.bottom;
    return bottomSafeAreaPadding > 0 ? bottomSafeAreaPadding : 20.0;
  }

  void _expandShrink() {
    setState(() {
      _expanded = widget.controller?.value ?? true;

      _cursorLedge = _expanded ? widget.cursorLedge : widget.collapsedCursorLedge;
    });

    var currentColor = _currentCursorColor(context);
    _updateIndexTabData(_currentSelectedIndex);
    var nextColor = _currentCursorColor(context);

    final positionTo = context.isRtl()
        ? -_convertToZeroRadialValue(_currentSelectedIndex)
        : _convertToZeroRadialValue(_currentSelectedIndex);

    _initAnimationAndStart(_positionAnimation?.value ?? 0, positionTo, currentColor, nextColor);
  }
}
