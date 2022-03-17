
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:flutter/material.dart';

class AdminTransactionScreen extends StatefulWidget {
  const AdminTransactionScreen({Key? key}) : super(key: key);

  @override
  _AdminTransactionScreenState createState() => _AdminTransactionScreenState();
}

class _AdminTransactionScreenState extends State<AdminTransactionScreen> {
  late ScrollController _scrollController;
  late List<Transaction> _transactionList;

  @override
  void initState() {
    _scrollController = ScrollController();
    _transactionList = Temp.transactionList!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Card(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Transaction', style: Theme.of(context).textTheme.headline3,),
                    ],
                  ),
                )),
              ),
              _ListView(_transactionList.reversed.toList()),
            ],
          ),
    );
  }
}

class _ListView extends StatefulWidget {
  final List<Transaction> list;

  const _ListView(this.list, {Key? key}) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  late List<Transaction> _filteredList;

  void selectAll() {
    setState(() {
      _filteredList = _filteredList.map<Transaction>((e) => e..selected = true).toList();
    });
  }

  void unselectAll() {
    setState(() {
      _filteredList = _filteredList.map<Transaction>((e) => e..selected = false).toList();
    });
  }

  @override
  void initState() {
    _filteredList = widget.list;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final o = _filteredList[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: o.selected,
                        onChanged: (val) {
                          if (val != null && val != o.selected) {
                            setState(() {
                              o.selected = val;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(o.created_at.split('T')[0], style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. Nota: ${o.id}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                  ExpansionTile(
                    title: const Text('Merchant'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
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
        childCount: _filteredList.length,
      ),
    );
  }
}