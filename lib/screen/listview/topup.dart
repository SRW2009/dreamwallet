
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
  SliverList _listView() {
    final list = Temp.topupList!;
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
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: const Text('Client'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.client.name)
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
        await Temp.fillTopupData();
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
                        Text('Topups', style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                        const SizedBox(height: 16.0,),
                        Text(
                          'Total Topup: ${EnVar.moneyFormat(Temp.topupTotal!)}',
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
