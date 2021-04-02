import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import 'package:user_manager/user_manager.dart';

import 'core_widgts.dart';

class CustomDrower extends StatefulWidget {
  @override
  _CustomDrowerState createState() => _CustomDrowerState();
}

class _CustomDrowerState extends State<CustomDrower> {
  User _user;
  final menuTextStyle = TextStyle(color: Color(0xFF373737), fontSize: 16.5);
  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _user = authProvider.user;
    return Drawer(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: _user.photoUrl == null || _user.photoUrl.isEmpty
                    ? BoxDecoration(gradient: mainLinearGradient)
                    : BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_user.photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    color: Colors.black26,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _userAdditionalDataWidget(
                          'Total des trajets',
                          '${_user.rideCount}',
                        ),
                        VerticalDivider(color: Colors.white),
                        _userAdditionalDataWidget(
                          'Note moyenne',
                          '${_user.rideCount}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Voir l'historique de vos trajets",
                  style: menuTextStyle,
                ),
                trailing: Icon(
                  Icons.history,
                  color: Colors.black38,
                ),
                onTap: () => _showScrollableDialog(
                  ListView(
                    children: _buildHistoryListTiles(),
                  ),
                  'Historique de trajets',
                ),
              ),
              ListTile(
                title: Text(
                  'Voir vos médailles',
                  style: menuTextStyle,
                ),
                trailing: SvgPicture.asset(
                  'assets/images/medal.svg',
                  width: 24,
                  height: 24,
                  color: Colors.black54,
                ),
                onTap: () => _showScrollableDialog(
                  GridView.count(
                    crossAxisCount: 2,
                    children: _buildTrophiesList(),
                  ),
                  'Médailles',
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              tileColor: Color(0xFFF1F1F1),
              onTap: () async {
                showWaitDialog('Déconnexion en cours', context);
                await authProvider
                    .signOut()
                    .then((_) => Navigator.of(context)
                        .popUntil((route) => route.isFirst))
                    .catchError((e) => _onSignOutFailed(e, context));
              },
              title: Text("Se déconnecter"),
              trailing: Icon(
                Icons.logout,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userAdditionalDataWidget(String title, String count) {
    final textStyle = TextStyle(color: Colors.white);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: textStyle,
        ),
        Text(
          count,
          textScaleFactor: 1.2,
          style: textStyle,
        ),
      ],
    );
  }

  Future<void> _onSignOutFailed(exception, BuildContext context) async {
    Navigator.of(context).pop();
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Une erreur est survenue lors de la déconnexion'),
          content: Text(exception.message),
          actions: [
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  List<ListTile> _buildHistoryListTiles() {
    var menuItems = <ListTile>[];
    _user.rideCountHistory.forEach((historyDate, rideCount) {
      menuItems.add(ListTile(
        title: Text(historyDate),
        trailing: Text('$rideCount'),
      ));
    });
    return menuItems;
  }

  void _showScrollableDialog(Widget child, String title) async {
    final screenSize = MediaQuery.of(context).size;
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Container(
          width: screenSize.width * .9,
          height: screenSize.height * .4,
          child: child,
        ),
        actions: [
          RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fermer'),
          ),
        ],
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        titlePadding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  List<Trophy> _buildTrophiesList() {
    var trophiesList = <Trophy>[];
    UserDataRepository.trophiesList.forEach((trophyLevel, trophy) {
      trophiesList.add(Trophy(
        level: trophyLevel,
        active: _user.trophies.contains(trophyLevel),
      ));
    });
    return trophiesList;
  }
}
