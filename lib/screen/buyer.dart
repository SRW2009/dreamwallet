
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/screen/topup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({Key? key}) : super(key: key);

  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {

  bool _isLoaded = false;
  int _bodyIndex = 0;
  final List<Widget> _bodies = [
    const BuyerScreen(), const TopupScreen(),
  ];

  void _load() async {
    String phone = (await Account.getAccount())!.mobile;
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
        title: const Text('Buyer Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
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

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({Key? key}) : super(key: key);

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((result) async {
      if (!_dialogShowing) {
        setState(() {
          _dialogShowing = true;
        });

        String resultText = result.code;
        String name = resultText.split(';')[0].split(':')[1];
        String phone = resultText.split(';')[1].split(':')[1];
        String amount = resultText.split(';')[2].split(':')[1];

        final isSuccess = await Navigator.push<bool>(context, DialogRoute(context: context, builder: (c) => AlertDialog(
          title: const Text('Perhatian'),
          content: Text('Are you sure you want to make a transaction with:\n'
              'Name: $name \n'
              'User: $phone \n'
              'Amount: $amount'),
          actions: [
            TextButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.pop(c, false);
              },
            ),
            TextButton(
              child: const Text('YES'),
              onPressed: () {
                Navigator.pop(c, true);
              },
            ),
          ],
        )));
        if (isSuccess != null && isSuccess) {
          _doPayment(name, phone, amount);
        }
        setState(() {
          _dialogShowing = false;
        });
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

  bool _dialogShowing = false;

  Future<void> _doPayment(String name, String phone, String amount, [int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        DateTime date = DateTime.now();
        Account? account = await Account.getAccount();
        if (account == null) return;
        String myPhone = account.mobile;
        int parsedAmount;
        try {
          parsedAmount = int.parse(amount);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to parse amount or date!')));

          return;
        }
        final response = await http.post(
          Uri.parse('${EnVar.API_URL_HOME}/transaction'),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            "is_debit": false,
            "transactionName": name,
            "transaction_amount": parsedAmount,
            "transaction_date": date.toIso8601String().split('T')[0],
            "transaction_depositor": myPhone,
            "transaction_receiver": phone
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_doPayment(name, phone, amount, ++retryCount);}
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
                      /*QRCodeDartScanView(
                        onCapture: (Result result) async {
                          if (!_dialogShowing) {
                            setState(() {
                              _dialogShowing = true;
                            });

                            String resultText = result.text;
                            String name = resultText.split(';')[0].split(':')[1];
                            String phone = resultText.split(';')[1].split(':')[1];
                            String amount = resultText.split(';')[2].split(':')[1];

                            final isSuccess = await Navigator.push<bool>(context, DialogRoute(context: context, builder: (c) => AlertDialog(
                              title: const Text('Perhatian'),
                              content: Text('Are you sure you want to make a transaction with:\n'
                                  'Name: $name \n'
                                  'User: $phone \n'
                                  'Amount: $amount'),
                              actions: [
                                TextButton(
                                  child: const Text('NO'),
                                  onPressed: () {
                                    Navigator.pop(c, false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('YES'),
                                  onPressed: () {
                                    Navigator.pop(c, true);
                                  },
                                ),
                              ],
                            )));
                            if (isSuccess != null && isSuccess) {
                              _doPayment(name, phone, amount);
                            }
                            setState(() {
                              _dialogShowing = false;
                            });
                          }
                        },
                      ),*/
                    ],
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
