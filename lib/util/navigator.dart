import 'package:flutter/material.dart';
import 'package:location_tracker/animations/page_transition.dart';
import 'package:location_tracker/util/consts.dart';

bool canPopPage() => navigatorKey.currentState?.canPop() ?? false;

Future<T?> pushToWithTransition<T>(
    BuildContext context,
    Widget page, {
      PageTransitionType? pageTransitionType,
      RouteSettings? settings,
    }) async {
  return Navigator.of(context).push(
    PageTransition(
      type: pageTransitionType ?? PageTransitionType.fadeIn,
      child: page,
    ) as Route<T>,
  );
}

Future<T?> pushReplacementWithTransition<T>(
    BuildContext context,
    Widget page, {
      PageTransitionType? pageTransitionType,
      RouteSettings? settings,
    }) async {
  return Navigator.of(context).pushReplacement(
    PageTransition(
      type: pageTransitionType ?? PageTransitionType.fadeIn,
      child: page,
    ) as Route<T>,
  );
}

Future<T?> pushAndRemoveUntilWithTransition<T>(
    BuildContext context,
    Widget page, {
      PageTransitionType? pageTransitionType,
      RouteSettings? settings,
    }) async {
  return Navigator.of(context).pushAndRemoveUntil(
    PageTransition(
      type: pageTransitionType ?? PageTransitionType.fadeIn,
      child: page,
    ) as Route<T>,
        (route) => false,
  );
}
