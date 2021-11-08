
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class _AdminHomeObject {
  int totalBuyer;
  int totalSeller;
  int totalMoney;
  int totalWithdraw;

  _AdminHomeObject(this.totalBuyer, this.totalSeller, this.totalMoney, this.totalWithdraw);
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  int _futureTryCount = 0;
  late Future<_AdminHomeObject> _future;
  Future<_AdminHomeObject> _getFuture([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        String url = '${EnVar.API_URL_HOME}/transactions';
        String url2 = '${EnVar.API_URL_HOME}/withdraw';
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );
        final response2 = await http.get(
          Uri.parse(url2),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        print(response2.statusCode);
        print(response2.body);
        if (response.statusCode == 200 && response2.statusCode == 200) {
          final data = jsonDecode(response.body)['response'];
          final data2 = jsonDecode(response2.body)['response'];

          int uang_buyer = data['uang_buyer'];
          int uang_seller = data['uang_seller'];
          int total_withdraw = data2['total_withdraw'];
          return _AdminHomeObject(
            (uang_buyer - uang_seller),
            (uang_seller - total_withdraw),
            (uang_buyer - total_withdraw),
            total_withdraw
          );
        }

        return _getFuture(++retryCount);
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return _getFuture(++retryCount);}
  }
  @override
  void initState() {
    _future = _getFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AdminHomeObject>(
      key: ValueKey(_futureTryCount),
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data!;

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Total Money:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                      const SizedBox(height: 8.0,),
                      Text(EnVar.MoneyFormat(data.totalMoney), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                      const Text('Total Buyer:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                      const SizedBox(height: 8.0,),
                      Text(EnVar.MoneyFormat(data.totalBuyer), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                      const Text('Total Seller:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                      const SizedBox(height: 8.0,),
                      Text(EnVar.MoneyFormat(data.totalSeller), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                      const Text('Total Withdrawn:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                      const SizedBox(height: 8.0,),
                      Text(EnVar.MoneyFormat(data.totalWithdraw), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        else if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: const Text('Reload'),
                        style: MyButtonStyle.primaryElevatedButtonStyle(context),
                        onPressed: () {
                          setState(() {
                            _future = _getFuture();
                            _futureTryCount++;
                          });
                        },
                      ),
                      const SizedBox(height: 14.0,),
                      const Text('Failed to calculate.', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 14.0,),
                    Text('Calculating...', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
