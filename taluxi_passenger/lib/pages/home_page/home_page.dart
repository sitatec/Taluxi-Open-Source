import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi/pages/call_page.dart';
import 'package:taluxi/state_managers/taxi_finder.dart';
import 'package:taluxi_common/taluxi_common.dart';
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
  TaxiFinder _taxiFinder;
  User _user;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    _taxiFinder = TaxiFinder(
      realTimeLocation: Provider.of<RealTimeLocation>(context, listen: false),
    );
    _user = _authProvider.user;
    _taxiFinder.taxiFinderState.listen(_manageTaxiFinderState);
  }

  @override
  void dispose() {
    _taxiFinder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final floatingActionButtonSize = deviceSize.height * 0.084;
    final userHasPhoto = (_authProvider.user.photoUrl != null &&
        _authProvider.user.photoUrl.isNotEmpty);
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => Stack(children: [
          Container(
            decoration: BoxDecoration(gradient: mainLinearGradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _headerContainer(deviceSize),
                BottomRoundedContainer(
                  deviceSize: deviceSize,
                  topBorderRadius: Radius.circular(40),
                )
              ],
            ),
          ),
          _userPhoto(userHasPhoto),
          _menuButton(context)
        ]),
      ),
      endDrawer: CustomDrower(),
      floatingActionButton: Container(
        child: CustomElevatedButton(
          child: Logo(backgroundColorIsOrange: true, fontSize: 43),
          height: floatingActionButtonSize,
          width: floatingActionButtonSize * 2.25,
          onTap: () async {
            await _taxiFinder.initialize(currentUserId: _user.uid);
            _taxiFinder.findNearest();
          },
        ),
        margin: EdgeInsets.only(bottom: deviceSize.height * .09),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    return Padding(
      padding: EdgeInsets.only(
          top: deviceSize.width * 0.35,
          right: deviceSize.width * 0.11,
          left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue",
            textScaleFactor: 3.4,
            style: TextStyle(fontFamily: 'PatuaOne', color: customWhiteColor),
          ),
          Center(
            child: Text(
              _user.formatedName,
              textScaleFactor: 2.9,
              style: TextStyle(fontFamily: 'PatuaOne', color: customWhiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _manageTaxiFinderState(TaxiFinderState taxiFinderState) {
    if (taxiFinderState is TaxiFound) {
      _callTaxisFound(taxiFinderState.taxiDriversFound);
    } else if (taxiFinderState is TaxiNotFound) {
      _showTaxiNotFoundDialog();
    } else
      showWaitDialog("Recherche d'un taxi disponible", context);
  }

  void _callTaxisFound(List<Map<String, Coordinates>> taxiDriversFound) {
    Navigator.of(context).pop(); // Pop the progress dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallPage(
          callRecipients: taxiDriversFound,
          currentUserId: _user.uid,
        ),
      ),
    );
  }

  void _showTaxiNotFoundDialog() {
    Navigator.of(context).pop(); // Pop the progress dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Indisponible'),
          content: Text(
            "Désolé, aucun conducteur n'est connecté dans la zone où vous vous trouvez actuellement, mais vous pouvez élargir la zone de recherche.",
          ),
          actions: [
            RaisedButton(
              child: Text('Élargir la zone'),
              onPressed: () {},
            ),
            RaisedButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
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
      height: deviceSize.height * 0.65,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: customWhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: topBorderRadius,
          topRight: topBorderRadius,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 34),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: deviceSize.width * 0.025),
          child: Text(
            "Pour trouver un taxi, vous avez juste à cliquez sur le bouton ci-dessous on s'occupera de vous mettre en contact avec le taxi le plus proche de l'endroit où vous vous trouvez actuellement.",
            textScaleFactor: 1.55,
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
