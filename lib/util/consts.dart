
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String kCapitalize(String s) => s[0].toUpperCase() + s.substring(1);

const kPrimaryColor = Colors.blue;