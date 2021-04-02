import 'package:flutter/material.dart';
import 'package:taluxi/pages/home_page/home_page.dart';
import 'package:taluxi_common/taluxi_common.dart';

import 'pages/welcome_page.dart';

// TODO implement Model view presenter (MVP), but test widgets before.
// TODO check test code coverage
void main() async {
  runApp(App(
    buildHomePage: () => HomePage(),
    buildWelcomePage: () => WelcomePage(),
  ));
}
