import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taluxi_common/taluxi_common.dart';

class CustomElevatedButton extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double elevation;
  final VoidCallback onTap;
  const CustomElevatedButton(
      {Key key,
      this.elevation = 6,
      this.child,
      this.width,
      this.height,
      this.onTap})
      : super(key: key);

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  double buttonElevation;
  bool buttonIsDown = false;
  final double buttonRaduis = 12;

  @override
  void initState() {
    super.initState();
    buttonElevation = widget.elevation;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.width,
        height: widget.height + widget.elevation,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: const [Color(0xFFE0A500), Color(0xFFDF7E00)]),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(buttonRaduis)),
              ),
              bottom: 0,
            ),
            AnimatedPositioned(
              child: Container(
                width: widget.width,
                height: widget.height,
                child: Center(child: widget.child),
                decoration: BoxDecoration(
                  gradient: mainLinearGradient,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(buttonRaduis),
                ),
              ),
              bottom: buttonElevation,
              duration: Duration(milliseconds: 350),
              onEnd: () {
                if (buttonIsDown) widget.onTap();
                setState(() {
                  buttonElevation = widget.elevation;
                  buttonIsDown = false;
                });
              },
            )
          ],
        ),
      ),
      // onTap: widget.onTap,
      onTapDown: (_) => setState(() {
        buttonElevation = 0;
        buttonIsDown = true;
        // widget.onTap();
      }),
    );
  }
}
