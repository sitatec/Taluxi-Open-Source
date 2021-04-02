import 'package:flutter/material.dart';

import 'review_page_widgets/arc_chooser.dart';
import 'review_page_widgets/smile_painter.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage({Key key}) : super(key: key);

  @override
  _ReviewPageState createState() => new _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  int slideValue = 200;
  int lastAnimPosition = 2;
  double _herperTextOpacity = 1;

  AnimationController animationController;

  List<ArcItem> arcItems = List<ArcItem>();

  ArcItem badArcItem;
  ArcItem ughArcItem;
  ArcItem okArcItem;
  ArcItem goodArcItem;

  Color startColor;
  Color endColor;

  @override
  void initState() {
    super.initState();

    badArcItem =
        ArcItem('MAUVAISE', [Color(0xFFfe0944), Color(0xFFfeae96)], 0.0);
    ughArcItem =
        ArcItem("MÉDIOCRE", [Color(0xFFF9D976), Color(0xfff39f86)], 0.0);
    okArcItem = ArcItem("CORRECT", [Color(0xFF21e1fa), Color(0xff3bb8fd)], 0.0);
    goodArcItem = ArcItem("BONNE", [Color(0xFF3ee98a), Color(0xFF41f7c7)], 0.0);

    arcItems.add(badArcItem);
    arcItems.add(ughArcItem);
    arcItems.add(okArcItem);
    arcItems.add(goodArcItem);

    startColor = Color(0xFF21e1fa);
    endColor = Color(0xff3bb8fd);

    animationController = new AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 400.0,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          slideValue = animationController.value.toInt();

          double ratio;

          if (slideValue <= 100) {
            ratio = animationController.value / 100;
            startColor =
                Color.lerp(badArcItem.colors[0], ughArcItem.colors[0], ratio);
            endColor =
                Color.lerp(badArcItem.colors[1], ughArcItem.colors[1], ratio);
          } else if (slideValue <= 200) {
            ratio = (animationController.value - 100) / 100;
            startColor =
                Color.lerp(ughArcItem.colors[0], okArcItem.colors[0], ratio);
            endColor =
                Color.lerp(ughArcItem.colors[1], okArcItem.colors[1], ratio);
          } else if (slideValue <= 300) {
            ratio = (animationController.value - 200) / 100;
            startColor =
                Color.lerp(okArcItem.colors[0], goodArcItem.colors[0], ratio);
            endColor =
                Color.lerp(okArcItem.colors[1], goodArcItem.colors[1], ratio);
          } else if (slideValue <= 400) {
            ratio = (animationController.value - 300) / 100;
            startColor =
                Color.lerp(goodArcItem.colors[0], badArcItem.colors[0], ratio);
            endColor =
                Color.lerp(goodArcItem.colors[1], badArcItem.colors[1], ratio);
          }
        });
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          margin: MediaQuery.of(context).padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Comment qualifieriez-vous l'expérience fournie par le conducteur ?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    (MediaQuery.of(context).size.width / 2.3) + 60),
                painter: SmilePainter(slideValue),
              ),
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: _herperTextOpacity,
                child: Container(
                  child: Text(
                    'Faites tourner le cercle pour choisir',
                    textScaleFactor: 1.2,
                  ),
                ),
              ),
              Stack(alignment: AlignmentDirectional.bottomCenter, children: <
                  Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: ArcChooser()
                    ..arcSelectedCallback = (int pos, ArcItem item) {
                      setState(() {
                        _herperTextOpacity = 0;
                      });
                      int animPosition = pos - 2;
                      if (animPosition > 3) {
                        animPosition = animPosition - 4;
                      }

                      if (animPosition < 0) {
                        animPosition = 4 + animPosition;
                      }

                      if (lastAnimPosition == 3 && animPosition == 0) {
                        animationController.animateTo(4 * 100.0);
                      } else if (lastAnimPosition == 0 && animPosition == 3) {
                        animationController.forward(from: 4 * 100.0);
                        animationController.animateTo(animPosition * 100.0);
                      } else if (lastAnimPosition == 0 && animPosition == 1) {
                        animationController.forward(from: 0.0);
                        animationController.animateTo(animPosition * 100.0);
                      } else {
                        animationController.animateTo(animPosition * 100.0);
                      }
                      lastAnimPosition = animPosition;
                    },
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(25),
                    elevation: 8.0,
                    child: InkWell(
                      onTap: () {
                        print(lastAnimPosition);
                      },
                      child: Container(
                        width: 150.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient:
                              LinearGradient(colors: [startColor, endColor]),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'VALIDER',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 21.00,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        Positioned(
          top: 42,
          left: 5,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        )
      ]),
    );
  }
}
