
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  SliverList _listView() {
    final list = Temp.transactionList!;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final o = list[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.created_at.split('T')[0], style: const TextStyle(
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
                        Text('No. Nota: ${o.id}', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(height: 6.0,),
                        Text(
                          EnVar.moneyFormat(o.total),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: const Text('Toko'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.merchant.name)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: list.length,
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Card(child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Transactions', style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                        const SizedBox(height: 16.0,),
                        Text(
                          'Total Transaction: ${EnVar.moneyFormat(Temp.transactionTotal!)}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14.0,
                            //fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(color: Colors.blue, height: 6.0,),
                ],
              )),
            ),
            _listView(),
          ],
        ),
      ),
    );
  }
}
