
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/listview/transaction.dart';
import 'package:dreamwallet/screen/listview/withdraw.dart';
import 'package:dreamwallet/screen/login.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:dreamwallet/style/inputdecoration.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({Key? key}) : super(key: key);

  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {

  int _bodyIndex = 0;
  bool _isLoaded = false;
  bool _isError = false;
  late final List<Widget> _bodies = [
    SellerScreen(reload: _reload,),
    const TransactionScreen(),
    const WithdrawScreen(),
  ];

  late final Future<Account?> _account;
  void _load() async {
    await Temp.fillTransactionData();
    await Temp.fillWithdrawData();

    if (Temp.transactionList != null && Temp.withdrawList != null) {
      setState(() {
        _isLoaded = true;
      });
      return;
    }
    setState(() {
      _isError = true;
    });
  }

  void _reload() {
    setState(() {
      _isLoaded = false;
      _isError = false;
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
        title: const Text('Seller Menu'),
        actions: [
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
              leading:const Icon(Icons.qr_code),
              title: const Text('Create QR Payment'),
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
              title: const Text('Transaction List'),
              onTap:() {
                setState(() {
                  _bodyIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: (_bodyIndex == 2),
              leading: const Icon(Icons.list),
              title: const Text('Withdraw List'),
              onTap:() {
                setState(() {
                  _bodyIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: (_isLoaded)
          ? _bodies[_bodyIndex]
          : (_isError)
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('Something\'s wrong.'),
                    ),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Reload'),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator(),),
    );
  }
}

class SellerScreen extends StatefulWidget {
  final Function() reload;

  const SellerScreen({Key? key, required this.reload}) : super(key: key);

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCon = TextEditingController();

  String? _qrData;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return ListView(
      children: [
        MaterialBanner(
          content: Text(
            'Saldo: ${EnVar.moneyFormat(Temp.transactionTotal!-Temp.withdrawTotal!)}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              style: MyButtonStyle.primaryTextButtonStyle(context),
              child: const Text('RELOAD'),
              onPressed: widget.reload,
            ),
          ],
        ),
        Stack(
          children: [
            Positioned(
              bottom: -20.0,
              right: -20.0,
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
                  maxHeight: screenSize.longestSide-140,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_qrData != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: QrImage(
                                data: _qrData!,
                                size: 250.0,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _amountCon,
                          keyboardType: TextInputType.number,
                          maxLength: 14,
                          decoration:
                          MyInputDecoration.primaryInputDecoration(context)
                              .copyWith(
                            prefixText: 'IDR ',
                            labelText: 'Transaction Amount',
                            prefixIcon: const Icon(Icons.payment),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please fill this field';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: MyButtonStyle.primaryElevatedButtonStyle(context),
                          child: const Text('Generate QR'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String amount = _amountCon.text;

                              Account? account = await Account.getAccount();
                              if (account == null) return;
                              String name = account.name;
                              int id = account.id;

                              try {
                                setState(() {
                                  _qrData = 'name:$name;id:$id;amount:$amount';
                                });
                              } catch (e) {}
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
