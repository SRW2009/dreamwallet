import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/screen/admin.dart';
import 'package:dreamwallet/screen/buyer.dart';
import 'package:dreamwallet/screen/login.dart';
import 'package:dreamwallet/screen/seller.dart';
import 'package:flutter/material.dart';

import 'objects/account/privileges/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const myMaterialColor = MaterialColor(
    0xFF0887CC,
    <int, Color> {
      50: Color(0xFFA4CDEB),
      100: Color(0xff91c8ed),
      200: Color(0xFF07AEE6),
      300: Color(0xFF0B9BE3),
      400: Color(0xFF0887CC),
      500: Color(0xFF089BCC),
      600: Color(0xFF086682),
      700: Color(0xFF036799),
      800: Color(0xFF085480),
      900: Color(0xFF063966),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreampay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: myMaterialColor)
            .copyWith(
          secondary: const Color.fromRGBO(217, 179, 67, 1.0),
          secondaryContainer: const Color.fromRGBO(165, 137, 51, 1.0),
          surface: const Color.fromRGBO(2, 62, 115, 1.0),
          background: const Color.fromRGBO(191, 186, 176, 1.0),
          error: const Color.fromRGBO(191, 44, 56, 1.0),
          onError: const Color.fromRGBO(254, 122, 186, 1.0),
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(
            color: Color.fromRGBO(2, 62, 115, 1.0),
            fontSize: 25.0,
            fontWeight: FontWeight.w800,
          ),
          headline2: TextStyle(
            color: Color.fromRGBO(2, 62, 115, 1.0),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          headline3: TextStyle(
            color: Colors.black,
            fontSize: 26.0,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            color: Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
          ),
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
          ),
          /*bodyText2: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
          button: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),*/
          caption: TextStyle(
            color: Colors.black,
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
          overline: TextStyle(
            color: Colors.red,
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _checkIsLoggedIn(BuildContext context) async {
    Account? account = await Account.getAccount();
    AccountPrivilege? privilege = account?.status;

    if (account != null) {
      if (privilege is Admin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
        return;
      }
      if (privilege is Buyer && account.isActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyerPage()),
        );
        return;
      }
      if (privilege is Seller && account.isActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerPage()),
        );
        return;
      }
      if (privilege is Cashier && account.isActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Container()),// TODO: const CashierPage()),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkIsLoggedIn(context);

    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
