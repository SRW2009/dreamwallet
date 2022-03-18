
import 'dart:async';
import 'dart:io';

import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/listview/topup.dart';
import 'package:dreamwallet/screen/listview/transaction.dart';
import 'package:dreamwallet/screen/login.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({Key? key}) : super(key: key);

  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {

  int _bodyIndex = 0;
  bool _isLoaded = false;
  bool _isError = false;
  late final List<Widget> _bodies = [
    BuyerScreen(reload: _reload,),
    const TopupScreen(),
    const TransactionScreen(),
  ];

  late final Future<Account?> _account;
  void _load() async {
    await Temp.fillTransactionData();
    await Temp.fillTopupData();

    if (Temp.transactionList != null && Temp.topupList != null) {
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
        title: const Text('Buyer Menu'),
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
              title: const Text('Scan QR Payment'),
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
            ListTile(
              selected: (_bodyIndex == 2),
              leading: const Icon(Icons.list),
              title: const Text('Transaction List'),
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

class BuyerScreen extends StatefulWidget {
  final Function() reload;

  const BuyerScreen({Key? key, required this.reload}) : super(key: key);

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  static const _transactionDelay = 8; // in second
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool _stopDoTransaction = false;
  bool _isLoadingTransaction = false;
  int _currentTimer = 0;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((result) async {
      if (!_stopDoTransaction) {
        String? resultText = result.code;
        if (resultText == null) return;

        String name = resultText.split(';')[0].split(':')[1];
        int? id = int.tryParse(resultText.split(';')[1].split(':')[1]);
        int? amount = int.tryParse(resultText.split(';')[2].split(':')[1]);
        if (id == null || amount == null) return;

        _stopDoTransaction = true;
        final clientAgree = await _askAgreementOnTransaction(name, amount);
        if (clientAgree) {
          setState(() {
            _isLoadingTransaction = true;
          });
          await _doTransaction(id, amount);
          setState(() {
            _currentTimer = _transactionDelay;
          });
          Timer.periodic(
            const Duration(seconds: 1),
            (timer) {
              if (_currentTimer == 1) {
                setState(() {
                  _currentTimer = 0;
                  _isLoadingTransaction = false;
                });
                timer.cancel();
                _stopDoTransaction = false;
                widget.reload();
                return;
              }

              setState(() {
                _currentTimer--;
              });
            },
          );
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Future<bool> _askAgreementOnTransaction(String name, int amount) async {
    final canPay = (Temp.topupTotal! - Temp.transactionTotal! - amount) >= 0;
    return await Navigator.push<bool>(context, DialogRoute(context: context, builder: (c) => AlertDialog(
      title: const Text('Attention'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to make a transaction with:\n\n'
              'Name: $name \n'
              'Amount: ${EnVar.moneyFormat(amount)}'),
          if (!canPay) const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text('Not enough money to make this transaction!', style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('NO'),
          onPressed: () {
            _stopDoTransaction = false;
            Navigator.pop(c, false);
          },
        ),
        TextButton(
          child: const Text('YES'),
          onPressed: canPay ? () {
            Navigator.pop(c, true);
          } : null,
        ),
      ],
    ))) ?? false;
  }

  Future<void> _doTransaction(int merchantId, int amount) async {
    final statusCode = await Request().clientCreateTransaction(merchantId, amount);

    if (statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed')));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        MaterialBanner(
          content: Text(
            'Saldo: ${EnVar.moneyFormat(Temp.topupTotal!-Temp.transactionTotal!)}',
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
        Expanded(
          child: Stack(
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
                        child: Stack(
                          children: [
                            const Center(
                              child: Text('No Camera Detected.'),
                            ),
                            QRView(
                              key: qrKey,
                              onQRViewCreated: _onQRViewCreated,
                              overlay: QrScannerOverlayShape(),
                            ),
                            if (_isLoadingTransaction) Container(
                              color: Colors.black.withOpacity(0.2),
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          value: (_currentTimer == 0)
                                              ? null
                                              : _currentTimer/_transactionDelay,
                                        ),
                                      ),
                                      if (_currentTimer != 0) Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: FittedBox(child: Text('$_currentTimer', style: const TextStyle(color: Colors.white),)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
