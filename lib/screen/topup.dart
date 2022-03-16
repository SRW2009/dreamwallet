
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:flutter/material.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({Key? key}) : super(key: key);

  @override
  _TopupScreenState createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {

  Widget _listView(List<Transaction> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var o in list)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.transaction_date.split('T')[0], style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),),
                      Text(o.is_debit ? 'Debit' : 'Kredit', style: TextStyle(
                        color: o.is_debit ? Colors.blue : Colors.deepOrange,
                        fontSize: 12.0,
                      ),),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No. Nota: ${o.id}', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(height: 6.0,),
                        Text(EnVar.moneyFormat(o.transaction_amount), style: TextStyle(
                          color: (o.is_debit) ? Colors.blue : Colors.deepOrange,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: const Text('Depositor'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.depositor.name)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 4.0,),
                            Text(o.depositor.mobile)
                          ],
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text('Receiver'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.receiver.name)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 4.0,),
                            Text(o.receiver.mobile)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        await Temp.fillTransactionData();
        setState(() {});
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Transactions', style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                    const SizedBox(height: 16.0,),
                    if (Temp.withdrawTotal == null) Text('Current wallet: ${EnVar.moneyFormat(Temp.total!)}', style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      //fontWeight: FontWeight.w500,
                    ),),
                    if (Temp.withdrawTotal != null) Text('Amount received: ${EnVar.moneyFormat(Temp.total!)}', style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      //fontWeight: FontWeight.w500,
                    ),),
                    if (Temp.withdrawTotal != null) Text('Total withdrawn: ${EnVar.moneyFormat(Temp.withdrawTotal!)}', style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      //fontWeight: FontWeight.w500,
                    ),),
                    if (Temp.withdrawTotal != null) Text('Current wallet: ${EnVar.moneyFormat(Temp.total! - Temp.withdrawTotal!)}', style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      //fontWeight: FontWeight.w500,
                    ),),
                  ],
                ),
              ),
              Container(color: Colors.blue, height: 6.0,),
            ],
          )),
          _listView(Temp.transactionList!),
          if (Temp.withdrawTotal != null) Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Withdraws', style: Theme.of(context).textTheme.headline3,),
                ),
                Container(color: Colors.red, height: 6.0,),
              ],
            ),
          ),
          if (Temp.withdrawTotal != null) for (var o in Temp.withdrawList!) Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.seller_id, style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.seller.name, style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(height: 6.0,),
                        Text(EnVar.moneyFormat(o.amount), style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
