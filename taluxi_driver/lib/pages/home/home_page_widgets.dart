import 'package:flutter/material.dart';

// TODO : Refactoring
class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String activeText;
  final String inactiveText;
  final double width;
  final double height;
  final double thumbSize;

  const CustomSwitch({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.width = 75,
    this.height = 33,
    this.activeColor,
    this.inactiveColor = Colors.grey,
    @required this.activeText,
    @required this.inactiveText,
    // this.activeTextColor = Colors.white70,
    // this.inactiveTextColor = Colors.white70,
  })  : thumbSize = height - 8,
        super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  final double radiusValue = 8;
  var loading = false;
  var textOpacity = 1.0;
  var loadingTextOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
        setState(() {
          loading = true;
          textOpacity = 0;
          loadingTextOpacity = 1;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.09),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusValue),
          color: widget.value ? widget.activeColor : widget.inactiveColor,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment:
                  widget.value ? Alignment.centerLeft : Alignment.centerRight,
              duration: Duration(milliseconds: 400),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.thumbSize * .41,
                  ),
                  child: loading
                      ? Text('Un instant svp')
                      : Text(
                          widget.value
                              ? widget.activeText
                              : widget.inactiveText,
                        ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: Duration(milliseconds: 400),
              alignment:
                  widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(5),
                height: widget.thumbSize,
                width: widget.thumbSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radiusValue),
                  color: Colors.white,
                ),
                child: loading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          widget.value
                              ? widget.activeColor
                              : widget.inactiveColor,
                        ),
                      )
                    : Image.asset(
                        widget.value
                            ? 'assets/images/valid.png'
                            : 'assets/images/cross.png',
                        fit: BoxFit.cover,
                      ),
              ),
              onEnd: () => setState(() {
                loading = false;
                loadingTextOpacity = 0;
                textOpacity = 1.0;
              }),
            )
          ],
        ),
      ),
    );
  }
}
