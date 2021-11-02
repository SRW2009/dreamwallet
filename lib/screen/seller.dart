
import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/topup.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:dreamwallet/style/inputdecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({Key? key}) : super(key: key);

  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {

  bool _isLoaded = false;
  int _bodyIndex = 0;
  final List<Widget> _bodies = [
    const SellerScreen(), const TopupScreen(),
  ];

  late Future<Account?> _account;
  void _load() async {
    _account = Account.getAccount();
    String phone = (await _account)!.mobile;
    await Temp.fillTransactionData(phone);

    if (Temp.transactionList != null) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Menu'),
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
          ],
        ),
      ),
      body: (_isLoaded) ? _bodies[_bodyIndex] : const Center(child: CircularProgressIndicator(),),
    );
  }
}

class SellerScreen extends StatefulWidget {
  const SellerScreen({Key? key}) : super(key: key);

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCon = TextEditingController();
  final _amountCon = TextEditingController();

  String? _qrData;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Stack(
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
              maxHeight: screenSize.longestSide,
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
                      controller: _nameCon,
                      keyboardType: TextInputType.name,
                      decoration:
                      MyInputDecoration.primaryInputDecoration(context)
                          .copyWith(
                        labelText: 'Transaction Name',
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please fill this field';
                        }
                        if (val.contains(';') || val.contains(':')) {
                          return 'Name can\'t contain one of the two forbidden symbols: \';\' or \':\'';
                        }
                        return null;
                      },
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
                          String name = _nameCon.text;
                          String amount = _amountCon.text;

                          Account? account = await Account.getAccount();
                          if (account == null) return;
                          String phone = account.mobile;

                          try {
                            setState(() {
                              _qrData = 'name:$name;mobile:$phone;amount:$amount';
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
    );
  }
}
