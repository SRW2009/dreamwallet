
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/admins/accountscreen.dart';
import 'package:dreamwallet/screen/admins/homescreen.dart';
import 'package:dreamwallet/screen/admins/topupscreen.dart';
import 'package:dreamwallet/screen/admins/withdrawscreen.dart';
import 'package:dreamwallet/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'admins/accountscreen.dart';
import 'admins/reportscreen.dart';
import 'admins/transactionscreen.dart';
import 'package:flutter/foundation.dart' as foundation;

class AdminPage extends StatefulWidget{
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage>{
  int _bodyIndex = 0;
  final List<Widget> _bodies = [];

  int _loadCount = 0;
  late Future<bool> _isLoaded;
  Future<bool> _load() async {
    await Temp.fillTransactionData();
    await Temp.fillWithdrawData();
    await Temp.fillTopupData();

    if (Temp.transactionList == null
        || Temp.withdrawList == null
        || Temp.topupList == null) return false;

    return true;
  }

  reload() {
    setState(() {
      _isLoaded = _load();
      _loadCount++;
    });
  }

  void _logout() async {
    await Account.unsetAccount();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void initState() {
    _bodies.addAll([
      const AdminHomeScreen(),
      const AdminAccountScreen(),
      const AdminTransactionScreen(),
      AdminWithdrawScreen(reload: reload,),
      AdminTopupScreen(reload: reload,),
      if (foundation.kIsWeb) const AdminReportScreen(),
    ]);
    _isLoaded = _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Admin Menu'),
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
                  _bodyIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 4),
              leading: const Icon(Icons.monetization_on),
              title: const Text('Topup'),
              onTap:() {
                setState(() {
                  _bodyIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 5),
              leading: const Icon(Icons.book),
              title: const Text('Report'),
              onTap:() {
                setState(() {
                  _bodyIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<bool>(
        key: ValueKey(_loadCount),
        future: _isLoaded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return _bodies[_bodyIndex];
            }

            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Failed to load. Please reload.',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0,),
                  ElevatedButton(
                    style: MyButtonStyle.primaryElevatedButtonStyle(context),
                    child: const Text('Reload'),
                    onPressed: reload,
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}