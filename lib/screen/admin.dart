
import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/screen/admins/accountscreen.dart';
import 'package:dreamwallet/screen/admins/homescreen.dart';
import 'package:dreamwallet/screen/admins/reportscreen.dart';
import 'package:dreamwallet/screen/admins/withdrawscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'admins/accountscreen.dart';
import 'admins/transactionscreen.dart';

class AdminPage extends StatefulWidget{
  const AdminPage({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage>{

  int _bodyIndex = 0;
  final List<Widget> _bodies = [];

  void _openTransactionWithAccount(Account account) {
    setState(() {
      _bodies[2] = AdminTransactionScreen(account: account);
      _bodyIndex = 2;
    });
  }

  void _openWithdrawWithAccount(Account account) {
    setState(() {
      _bodies[3] = AdminWithdrawScreen(account: account);
      _bodyIndex = 3;
    });
  }

  @override
  void initState() {
    _bodies.addAll([
      const AdminHomeScreen(),
      AdminAccountScreen(_openTransactionWithAccount, _openWithdrawWithAccount),
      const AdminTransactionScreen(),
      const AdminWithdrawScreen(),
      const AdminReportScreen(),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Admin Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: null,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/dreampaybg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              selected: (_bodyIndex == 0),
              leading:const Icon(Icons.home),
              title: const Text('Home'),
              onTap: (){
                setState(() {
                  _bodyIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 1),
              leading:const Icon(Icons.account_box),
              title: const Text('Account'),
              onTap: (){
                setState(() {
                  _bodyIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 2),
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Transaction'),
              onTap:() {
                setState(() {
                  _bodies[2] = const AdminTransactionScreen();
                  _bodyIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 3),
              leading: const Icon(Icons.account_balance),
              title: const Text('Withdraw'),
              onTap:() {
                setState(() {
                  _bodies[3] = const AdminWithdrawScreen();
                  _bodyIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 4),
              leading: const Icon(Icons.book),
              title: const Text('Report'),
              onTap:() {
                setState(() {
                  _bodyIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _bodies[_bodyIndex],
    );
  }
}