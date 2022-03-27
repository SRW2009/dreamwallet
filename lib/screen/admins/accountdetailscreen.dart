
import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/dialogs/migrate_dialog.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:flutter/material.dart';

class AdminAccountDetailScreen extends StatefulWidget {
  final Account account;

  const AdminAccountDetailScreen({Key? key, required this.account}) : super(key: key);

  @override
  _AdminAccountDetailScreenState createState() => _AdminAccountDetailScreenState();
}

class _AdminAccountDetailScreenState extends State<AdminAccountDetailScreen> {
  late ScrollController _scrollController;
  late List<Topup> _topupList;
  late List<Transaction> _transactionList;
  late double _totalTopup;
  late double _totalTransaction;

  int _rebuildCount = 0;

  void load() {
    double total1 = 0;
    _topupList = Temp.topupList!
        .where((element) => element.client == widget.account).toList();
    for (var o in _topupList) {
      total1 += o.total;
    }
    _totalTopup = total1;
    double total2 = 0;
    _transactionList = Temp.transactionList!
        .where((element) => element.client == widget.account).toList();
    for (var o in _transactionList) {
      total2 += o.total;
    }
    _totalTransaction = total2;
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Detail'),
      ),
      body: Padding(
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
                        Text(
                          '(${widget.account.id}) ${widget.account.name}', style: Theme.of(context).textTheme.headline3,),
                      ],
                    ),
                  )),
                ),
                SliverToBoxAdapter(
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _headerView(),
                  )),
                ),
                _dividerView('Topup List', Colors.blue),
                _TopupList(
                  _topupList.reversed.toList(),
                  key: ValueKey('tp_ls.$_rebuildCount'),
                ),
                _dividerView('Transaction List', Colors.red),
                _TransactionList(
                  _transactionList.reversed.toList(),
                  key: ValueKey('tr_ls.$_rebuildCount'),
                ),
              ],
            ),
      ),
    );
  }

  Widget _headerView() {
    final totalTopupText = Text(
      'Total Topup: ${EnVar.moneyFormat(_totalTopup)}',
      style: Theme.of(context).textTheme.subtitle1,
      key: ValueKey('tl_tp_tx.$_rebuildCount'),
    );
    final totalTransactionText = Text(
        'Total Transaction: ${EnVar.moneyFormat(_totalTransaction)}',
      style: Theme.of(context).textTheme.subtitle1,
      key: ValueKey('tl_tr_tx.$_rebuildCount'),
    );
    final migrateBtn = ElevatedButton(
      child: const Text('Migrate'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => MigrateDialog(
            selectedClient: widget.account,
            onSave: () async {
              load();
              setState(() {
                _rebuildCount++;
              });
            },
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Detail', style: Theme.of(context).textTheme.headline4,),
        const SizedBox(height: 16.0),
        LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.minWidth < 650) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(child: totalTopupText, fit: BoxFit.scaleDown,),
                    FittedBox(child: totalTransactionText, fit: BoxFit.scaleDown,),
                    migrateBtn,
                  ],
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  totalTopupText,
                  totalTransactionText,
                  migrateBtn,
                ],
              );
            }
        ),
      ],
    );
  }

  Widget _dividerView(String title, Color color) {
    return SliverToBoxAdapter(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title, style: Theme.of(context).textTheme.headline3,),
            ),
            Container(
              color: color,
              width: Size.infinite.width,
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopupList extends StatefulWidget {
  final List<Topup> list;

  const _TopupList(this.list, {Key? key}) : super(key: key);

  @override
  _TopupListState createState() => _TopupListState();
}

class _TopupListState extends State<_TopupList> {
  late List<Topup> _filteredList;

  void selectAll() {
    setState(() {
      _filteredList = _filteredList.map<Topup>((e) => e..selected = true).toList();
    });
  }

  void unselectAll() {
    setState(() {
      _filteredList = _filteredList.map<Topup>((e) => e..selected = false).toList();
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
                    title: Text(o.topuppedByCashier() ? 'Cashier' : 'Admin'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.topuppedByCashier() ? o.cashier!.name : o.admin!.name),
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

class _TransactionList extends StatefulWidget {
  final List<Transaction> list;

  const _TransactionList(this.list, {Key? key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<_TransactionList> {
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