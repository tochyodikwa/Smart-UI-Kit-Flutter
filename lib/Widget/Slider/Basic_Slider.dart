import 'dart:math' as math;
import 'package:flutter/material.dart';

class Slider_Basic extends StatefulWidget {
  static const String routeName = '/material/slider';

  @override
  _SliderRouteState createState() => _SliderRouteState();
}

Path _triangle(double size, Offset thumbCenter, {bool invert = false}) {
  final Path thumbPath = Path();
  final double height = math.sqrt(3.0) / 2.0;
  final double halfSide = size / 2.0;
  final double centerHeight = size * height / 3.0;
  final double sign = invert ? -1.0 : 1.0;
  thumbPath.moveTo(thumbCenter.dx - halfSide, thumbCenter.dy + sign * centerHeight);
  thumbPath.lineTo(thumbCenter.dx, thumbCenter.dy - 2.0 * sign * centerHeight);
  thumbPath.lineTo(thumbCenter.dx + halfSide, thumbCenter.dy + sign * centerHeight);
  thumbPath.close();
  return thumbPath;
}

class _CustomThumbShape extends SliderComponentShape {
  static const double _thumbSize = 4.0;
  static const double _disabledThumbSize = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return isEnabled ? const Size.fromRadius(_thumbSize) : const Size.fromRadius(_disabledThumbSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledThumbSize,
    end: _thumbSize,
  );

  @override
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    // new line added
    Size sizeWithOverflow,
    /*The missing link*/
    double textScaleFactor,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double size = _thumbSize * sizeTween.evaluate(enableAnimation);
    final Path thumbPath = _triangle(size, thumbCenter);
    canvas.drawPath(thumbPath, Paint()..color = colorTween.evaluate(enableAnimation));
  }
}

class _CustomValueIndicatorShape extends SliderComponentShape {
  static const double _indicatorSize = 4.0;
  static const double _disabledIndicatorSize = 3.0;
  static const double _slideUpHeight = 40.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? _indicatorSize : _disabledIndicatorSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledIndicatorSize,
    end: _indicatorSize,
  );

  @override
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    // new line added
    Size sizeWithOverflow,
    /*The missing link*/
    double textScaleFactor,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    final Tween<double> slideUpTween = Tween<double>(
      begin: 0.0,
      end: _slideUpHeight,
    );
    final double size = _indicatorSize * sizeTween.evaluate(enableAnimation);
    final Offset slideUpOffset = Offset(0.0, -slideUpTween.evaluate(activationAnimation));
    final Path thumbPath = _triangle(
      size,
      thumbCenter + slideUpOffset,
      invert: true,
    );
    final Color paintColor = enableColor.evaluate(enableAnimation).withAlpha((255.0 * activationAnimation.value).round());
    canvas.drawPath(
      thumbPath,
      Paint()..color = paintColor,
    );
    canvas.drawLine(
        thumbCenter,
        thumbCenter + slideUpOffset,
        Paint()
          ..color = paintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
    labelPainter.paint(canvas, thumbCenter + slideUpOffset + Offset(-labelPainter.width / 2.0, -labelPainter.height - 4.0));
  }
}

class _SliderRouteState extends State<Slider_Basic> {
  double _value = 25.0;
  double _numericValue = 25.0;
  double _discreteValue = 20.0;
  double _discretesThemeValue = 20.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //******************************** Simple Slider ***************************
                Slider(
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade400,
                  value: _value,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (double value) {
                    setState(() {
                      _value = value;
                    });
                  },
                ),
                const Text('Simple'),
              ],
            ),

            //******************************** Numerical value slider ***************************
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        activeColor: Colors.black,
                        inactiveColor: Colors.grey.shade400,
                        value: _numericValue,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (double value) {
                          setState(() {
                            _numericValue = value;
                          });
                        },
                      ),
                    ),
                    Semantics(
                      label: 'Numerical value',
                      child: Container(
                        width: 48,
                        height: 48,
                        child: TextField(
                          onSubmitted: (String value) {
                            final double newValue = double.tryParse(value);
                            if (newValue != null && newValue != _numericValue) {
                              setState(() {
                                _numericValue = newValue.clamp(0, 100);
                              });
                            }
                          },
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: _numericValue.toStringAsFixed(0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text('Numerical Value'),
              ],
            ),

            //******************************** disable slider ***************************
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Slider(activeColor: Colors.grey.shade200, value: 0.25, onChanged: null),
                Text('Disabled'),
              ],
            ),

            //******************************** discrete slider ***************************
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Slider(
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade400,
                  value: _discreteValue,
                  min: 0.0,
                  max: 200.0,
                  divisions: 5,
                  label: '${_discreteValue.round()}',
                  onChanged: (double value) {
                    setState(() {
                      _discreteValue = value;
                    });
                  },
                ),
                const Text('Discrete'),
              ],
            ),

            //******************************** discrete with custom theme ***************************
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.black26,
                    activeTickMarkColor: Colors.white70,
                    inactiveTickMarkColor: Colors.black,
                    overlayColor: Colors.black12,
                    thumbColor: Colors.black,
                    valueIndicatorColor: Colors.black54,
                    thumbShape: _CustomThumbShape(),
                    valueIndicatorShape: _CustomValueIndicatorShape(),
                    valueIndicatorTextStyle: theme.accentTextTheme.bodyText1.copyWith(color: Colors.black87),
                  ),
                  child: Slider(
                    value: _discretesThemeValue,
                    min: 0.0,
                    max: 100.0,
                    divisions: 5,
                    semanticFormatterCallback: (double value) => value.round().toString(),
                    label: '${_discretesThemeValue.round()}',
                    onChanged: (double value) {
                      setState(() {
                        _discretesThemeValue = value;
                      });
                    },
                  ),
                ),
                const Text('Discrete with Custom Theme'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
