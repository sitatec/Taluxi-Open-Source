import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user_manager/user_manager.dart';

import '../constants/colors.dart';

class OAuthButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final String initials;
  final void Function() onClick;

  const OAuthButton({
    Key key,
    this.height = 57.1,
    this.width,
    @required this.initials,
    this.text,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: height,
        width: width, //?? MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1959a9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff2872ba),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacebookLoginButton extends StatelessWidget {
  final void Function() onClick;
  const FacebookLoginButton({Key key, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuthButton(
      onClick: onClick,
      initials: "f",
      text: "Se connecter avec Facebook",
    );
  }
}

void showWaitDialog(String title, BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: WaitWidget(),
      );
    },
  );
}

class WaitWidget extends StatelessWidget {
  const WaitWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height * 0.27,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SpinKitCubeGrid(
            color: Color(0xFFFFAE16),
          ),
          Text(
            "   Veuillez patiantez un instant s'il vous plait.   ",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Future<void> showTrophiesWonDialog(
    String trophies, BuildContext context) async {
  final screenSize = MediaQuery.of(context).size;
  var trophiesWidgets = <Trophy>[];
  trophies.split('').forEach((trophyLevel) {
    trophiesWidgets.add(Trophy(
      level: trophyLevel,
      active: true,
      size: screenSize.width * .38,
      namePrefix: 'Vous avez éffectué ',
      spaceBetweenImageAndText: 15,
    ));
  });
  final isSingleTrophy = trophiesWidgets.length == 1;
  final trophiesCountText = isSingleTrophy ? 'une' : trophiesWidgets.length;
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Félicitaion, vous avez gagné $trophiesCountText médaille' +
                (isSingleTrophy ? '' : 's'),
            textAlign: TextAlign.center,
            textScaleFactor: .94,
          ),
          content: Container(
            height: screenSize.height * .34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isSingleTrophy)
                  Text(
                    'Faites défiler vers la droite pour voir la suivante',
                    textScaleFactor: .83,
                  ),
                SizedBox(
                  height: screenSize.height * .009,
                ),
                Container(
                  width: screenSize.width * .9,
                  height: screenSize.height * .3,
                  child: PageView(
                    children: trophiesWidgets,
                  ),
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.only(bottom: 0, top: 10),
          actions: [
            RaisedButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      });
}

// ignore: must_be_immutable
class Logo extends StatelessWidget {
  Color _taxiColor;
  final double fontSize;
  Color luxeColor;

  Logo({
    Key key,
    bool backgroundColorIsOrange = false,
    this.fontSize = 30,
    this.luxeColor,
    Color taxiColor,
  }) : super(key: key) {
    _taxiColor = taxiColor ??
        (backgroundColorIsOrange ? Colors.white : mainLightLessColor);
  }
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Ta',
        style: TextStyle(
          fontFamily: 'LobsterTwo',
          fontSize: fontSize,
          color: _taxiColor,
        ),
        children: [
          TextSpan(
              text: 'lu',
              style: TextStyle(
                  fontSize: fontSize, color: luxeColor ?? Color(0xFF424141))),
          TextSpan(
            text: 'xi',
            style: TextStyle(color: _taxiColor, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

class Trophy extends StatelessWidget {
  final trophies = UserDataRepository.trophiesList;
  final String level;
  final bool active;
  final double size;
  final String namePrefix;
  final double spaceBetweenImageAndText;
  const Trophy({
    @required this.level,
    this.active = false,
    this.size = 74,
    this.namePrefix = '',
    this.spaceBetweenImageAndText = 0,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/trophies/$level.svg',
              width: size,
              height: size,
            ),
            if (!active)
              Container(
                width: size + 22,
                height: size + 7,
                color: Colors.black38,
                child: Text(
                  'Bloquée',
                  style: TextStyle(
                      color: Color(0xFFFDFDFD), fontWeight: FontWeight.w600),
                ),
                alignment: Alignment.center,
              )
          ],
        ),
        SizedBox(
          height: spaceBetweenImageAndText,
        ),
        Text(
          namePrefix + trophies[level].name,
          textScaleFactor: .97,
          textAlign: TextAlign.center,
        )
      ],
    ));
  }
}
