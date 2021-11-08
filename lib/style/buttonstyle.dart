
import 'package:flutter/material.dart';

class MyButtonStyle {
  static ButtonStyle primaryElevatedButtonStyle(BuildContext context) => ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
    backgroundColor: MaterialStateProperty.resolveWith<Color?>((state) {
      if (state.contains(MaterialState.disabled)) return Colors.grey[500];
      return Theme.of(context).colorScheme.secondary;
    }),
    foregroundColor: MaterialStateProperty.resolveWith<Color?>((state) {
      if (state.contains(MaterialState.disabled)) return Colors.white;
      return Colors.black;
    }),
    //textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button),
  );

  static ButtonStyle primaryTextButtonStyle(BuildContext context) => ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
    foregroundColor: MaterialStateProperty.resolveWith<Color?>((state) {
      if (state.contains(MaterialState.disabled)) return Colors.grey[600];
      return Theme.of(context).colorScheme.secondary;
    }),
    //textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button),
  );

  static ButtonStyle secondaryElevatedButtonStyle(BuildContext context) => ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onError),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    //textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button),
  );

  static ButtonStyle disabledElevatedButtonStyle(BuildContext context) => ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    //textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button),
  );
}