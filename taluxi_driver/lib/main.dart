import 'package:flutter/material.dart';
import 'package:taluxi_common/taluxi_common.dart';

import 'pages/home/home_page.dart';
import 'pages/welcome_page.dart';

// TODO implement Model view presenter (MVP), but test widgets before. 581 700 0918
// TODO check test code coverage
void main() async {
  runApp(App(
    buildHomePage: () => HomePage(),
    buildWelcomePage: () => WelcomePage(),
  ));
}

// TODO: write copyright in all files.
