
import 'package:dreamwallet/screen/admins/accountscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'admins/accountscreen.dart';
import 'admins/topupscreen.dart';

class AdminPage extends StatefulWidget{
  const AdminPage({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage>{

  int _bodyIndex = 0;
  final List<Widget> _bodies = [];

  void _openTransactionWithAccountId(String accountId) {
    setState(() {
      _bodies[1] = AdminTopupScreen(accountId: accountId,);
      _bodyIndex = 1;
    });
  }

  @override
  void initState() {
    _bodies.addAll([
      AdminAccountScreen(_openTransactionWithAccountId),
      const AdminTopupScreen(),
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
              leading:const Icon(Icons.account_box),
              title: const Text('Account'),
              onTap: (){
                setState(() {
                  _bodyIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 1),
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Transaction'),
              onTap:() {
                setState(() {
                  _bodies[1] = const AdminTopupScreen();
                  _bodyIndex = 1;
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