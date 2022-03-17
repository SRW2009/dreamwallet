
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dreamwallet/dialogs/topup_create_dialog.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/listview/topup.dart';
import 'package:dreamwallet/screen/listview/transaction.dart';
import 'package:dreamwallet/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({Key? key}) : super(key: key);

  @override
  _CashierPageState createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {

  bool _isLoaded = false;
  int _bodyIndex = 0;
  final List<Widget> _bodies = [
    const CashierScreen(), const TopupScreen(),
  ];

  late final Future<Account?> _account;
  void _load() async {
    await Temp.fillTopupData();

    if (Temp.topupList != null) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  void reload() {
    setState(() {
      _isLoaded = false;
    });
    _load();
  }

  void _logout() async {
    await Account.unsetAccount();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void onCreateTopup() async {
    await showDialog(context: context, builder: (context) =>
        TopupCreateDialog(onSave: doTopup),
    );
  }

  void doTopup(int clientId, double total) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading...')));

    final statusCode = await Request().cashierTopup(total, clientId);

    if (statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      reload();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed')));
    }
  }

  @override
  void initState() {
    _account = Account.getAccount();
    _load();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Menu'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: reload,),
          IconButton(icon: const Icon(Icons.power_settings_new), onPressed: _logout,),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            FutureBuilder<Account?>(
              future: _account,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;

                  return UserAccountsDrawerHeader(
                    accountName: Text(data.name),
                    accountEmail: Text(data.mobile),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/dreampaybg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                return const UserAccountsDrawerHeader(
                  accountName: null,
                  accountEmail: null,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/dreampaybg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            ),
            ListTile(
              selected: (_bodyIndex == 0),
              leading:const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: (){
                setState(() {
                  _bodyIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 1),
              leading: const Icon(Icons.list),
              title: const Text('Topup List'),
              onTap:() {
                setState(() {
                  _bodyIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: (_isLoaded) ? _bodies[_bodyIndex] : const Center(child: CircularProgressIndicator(),),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: onCreateTopup,
      ),
    );
  }
}

class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {

  late double _moneyOnHand;
  late double _moneyReported;

  @override
  void initState() {
    _moneyOnHand = Temp.cashierMoneyOnHand!;
    _moneyReported = Temp.cashierMoneyReported!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          bottom: -20.0, right: -20.0,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'images/dreamland-black.png',
              height: 250.0,
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.shortestSide,
              maxHeight: screenSize.longestSide,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Money-On-Hand:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                        const SizedBox(height: 8.0,),
                        Text(EnVar.moneyFormat(_moneyOnHand),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Money Reported:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                        const SizedBox(height: 8.0,),
                        Text(EnVar.moneyFormat(_moneyReported),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
