import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi_common/taluxi_common.dart';
import 'package:taluxi_driver/pages/home/state_manager.dart' as sm;
import 'package:user_manager/user_manager.dart';

import 'home_page_widgets.dart';

final customWhiteColor = Color(0xF5FCFAFA);

//TODO Refactoring : extracted widgets for better names.
// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthenticationProvider _authProvider;
  User _user;
  sm.StateManager _stateManager;
  var _connected = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final realtimerLocation =
        Provider.of<RealTimeLocation>(context, listen: false);
    _user = _authProvider.user;
    _stateManager = sm.StateManager(
      context: context,
      currentUserId: _user.uid,
      realTimeLocation: realtimerLocation,
    );
    _stateManager.state.listen(_manageState);
  }

  void _manageState(sm.State state) {
    if (state is sm.ConnectionFailed) {
      _showErrorDialog(state.reason, 'Échec de la connection');
    } else if (state is sm.DisconnectionFailed) {
      _showErrorDialog(state.reason, 'Échec de la déconnection');
    } else if (state is sm.LocationUpdateFailed) {
      _showErrorDialog(
          state.reason, 'Échec de la mis à jour de votre localisation.');
    }
  }

  void _showErrorDialog(String errorMessage, [String title = "Erreur"]) {
    setState(() => null); // Disable loading.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(errorMessage),
        actions: [
          RaisedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Ok"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final userHasPhoto = (_authProvider.user.photoUrl != null &&
        _authProvider.user.photoUrl.isNotEmpty);
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerContainer(deviceSize),
              BottomRoundedContainer(
                deviceSize: deviceSize,
                topBorderRadius: Radius.circular(40),
              ),
              SizedBox(),
              CustomSwitch(
                onChanged: (value) async {
                  if (_connected) {
                    await _stateManager.disconnectsDriver();
                  } else {
                    await _stateManager.connectsDriver();
                  }
                  setState(() => _connected = value);
                },
                value: _connected,
                activeText: '  CONNECTÉ',
                inactiveText: 'DÉCONNECTÉ',
                height: deviceSize.height * .062,
                width: deviceSize.width * .48,
                activeColor: Colors.green,
                inactiveColor: Color(0x8EFF0000),
              ),
              SizedBox()
            ],
          ),
          _userPhoto(userHasPhoto),
          _menuButton(context)
        ]),
      ),
      endDrawer: CustomDrower(),
    );
  }

  Positioned _menuButton(BuildContext context) {
    return Positioned(
      right: 10,
      top: 60,
      child: Container(
        decoration: BoxDecoration(
          color: customWhiteColor,
          borderRadius: BorderRadius.circular(9),
        ),
        child: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    );
  }

  Positioned _userPhoto(bool userHasPhoto) {
    return Positioned(
      left: 10,
      top: 60,
      child: Container(
        height: 48,
        width: 49,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              offset: Offset(0, 2),
              color: Colors.black12,
            )
          ],
          image: userHasPhoto
              ? DecorationImage(
                  image: NetworkImage(_user.photoUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: customWhiteColor,
          borderRadius: BorderRadius.circular(9),
        ),
        child: userHasPhoto
            ? null
            : Icon(Icons.person, color: Colors.black38, size: 43),
      ),
    );
  }

  Widget _headerContainer(Size deviceSize) {
    return Container(
      decoration: BoxDecoration(gradient: mainLinearGradient),
      padding: EdgeInsets.only(top: deviceSize.width * 0.4),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontSize: 17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stats de la journée",
                textAlign: TextAlign.center,
                textScaleFactor: 1.1,
              ),
              Divider(color: Colors.white),
              Container(
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Appels réçus"),
                        Text("9", textScaleFactor: 1.1),
                      ],
                    ),
                    VerticalDivider(color: Colors.white),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Course éffectuée"),
                        Text("9", textScaleFactor: 1.1),
                      ],
                    ),
                    VerticalDivider(color: Colors.white),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Ratio"),
                        Text("100%", textScaleFactor: 1.1),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomRoundedContainer extends StatelessWidget {
  const BottomRoundedContainer({
    Key key,
    @required this.deviceSize,
    @required this.topBorderRadius,
  }) : super(key: key);

  final Size deviceSize;
  final Radius topBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: deviceSize.height * 0.6,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        // margin: EdgeInsets.only(top: 34),
        padding: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.only(left: deviceSize.width * 0.025),
          child: Text(
            "Pour trouver un taxi, vous avez juste à cliquez sur le bouton ci-dessous on s'occupera de vous mettre en contact avec le taxi le plus proche de l'endroit où vous vous trouvez actuellement.    Pour trouver un taxi, vous avez juste à cliquez sur le bouton ci-dessous on s'occupera de vous mettre en contact avec le taxi le plus proche de l'endroit où vous vous trouvez actuellement.",
            textScaleFactor: 1.35,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
