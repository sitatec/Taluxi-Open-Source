import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/constants/colors.dart';
import '../core/widgets/core_widgts.dart';

class WaitingPage extends StatefulWidget {
  final String message;
  const WaitingPage({Key key, this.message}) : super(key: key);

  @override
  _SlashPageState createState() => _SlashPageState();
}

class _SlashPageState extends State<WaitingPage> {
  var spinOpacity = 0.0;
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(Duration(seconds: 4), () => setState(() => spinOpacity = 1));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFFF1F1F1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Logo(
              fontSize: 70,
            ),
            SizedBox(height: 10),
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: spinOpacity,
              child: Column(
                children: [
                  SpinKitWave(
                    type: SpinKitWaveType.start,
                    itemCount: 6,
                    size: 37,
                    color: mainLightLessColor,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.message ?? 'Chargement en cours',
                    textScaleFactor: .95,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
