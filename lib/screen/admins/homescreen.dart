
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:flutter/material.dart';

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

  late _AdminHomeObject data;

  @override
  void initState() {
    data = _AdminHomeObject(
        (Temp.topupTotal! - Temp.transactionTotal!).toInt(),
        (Temp.transactionTotal! - Temp.withdrawTotal!).toInt(),
        (Temp.topupTotal! - Temp.withdrawTotal!).toInt(),
        Temp.withdrawTotal!.toInt()
    );
    print([Temp.topupTotal, Temp.transactionTotal, Temp.withdrawTotal]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                Text(EnVar.moneyFormat(data.totalMoney), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                Text(EnVar.moneyFormat(data.totalBuyer), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                Text(EnVar.moneyFormat(data.totalSeller), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
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
                Text(EnVar.moneyFormat(data.totalWithdraw), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
