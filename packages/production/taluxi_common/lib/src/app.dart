import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location/real_time_location.dart';
import 'pages/waiting_page.dart';
import 'package:user_manager/user_manager.dart';

import 'pages/connection_wrong_page.dart';

typedef PageBuilder = Widget Function();

class App extends StatelessWidget {
  final PageBuilder buildHomePage;
  final PageBuilder buildWelcomePage;
  App({@required this.buildHomePage, @required this.buildWelcomePage});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
        title: 'Taluxi',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Color(0xFFFFA41C),
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: initializeBackEndServices(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ConnectionWrongPage()),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return ChangeNotifierProvider<AuthenticationProvider>.value(
                value: AuthenticationProvider.instance,
                child: AppEntryPoint(buildHomePage, buildWelcomePage),
              );
            }
            return WaitingPage();
          },
        ));
  }
}

// ignore: must_be_immutable
class AppEntryPoint extends StatelessWidget {
  final PageBuilder buildHomePage;
  final PageBuilder buildWelcomePage;
  AppEntryPoint(this.buildHomePage, this.buildWelcomePage);

  AuthState _currentAuthState;
  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
// TODO create all theme constante and configure all theme default values.
    return StreamBuilder(
      stream: authProvider.authBinaryState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ConnectionWrongPage()),
          );
        } else if (snapshot.hasData) {
          if (_currentAuthState != snapshot.data) {
            if (snapshot.data == AuthState.authenticated) {
              return Provider.value(
                value: RealTimeLocation.instance,
                child: buildHomePage(),
              );
            } else if (snapshot.data == AuthState.unauthenticated) {
              return buildWelcomePage();
            }
          }
        }
        return WaitingPage();
      },
    );
  }
}
