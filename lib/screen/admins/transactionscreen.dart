
import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/objects/account/account.dart';
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
  // insert null cashier to nullify filter
  final _dummyClient = Account.parseClient({'id':-1, 'name':''});
  late ScrollController _scrollController;
  late List<Transaction> _transactionList;

  int _listRebuildCount = 0;
  List<Account>? _clientList;
  double? _clientTotalTransaction;

  @override
  void initState() {
    _scrollController = ScrollController();
    _transactionList = Temp.transactionList!;
    super.initState();
  }

  void _doFilter(Account item) {
    _transactionList = Temp.transactionList!;
    if (item == _dummyClient) {
      setState(() {
        _clientTotalTransaction = null;
        _listRebuildCount++;
      });
      return;
    }
    double total = 0;
    _transactionList = _transactionList
        .where((element) => element.client == item).toList();
    for (var o in _transactionList) {
      total += o.total;
    }
    setState(() {
      _clientTotalTransaction = total;
      _listRebuildCount++;
    });
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
              SliverToBoxAdapter(
                child: Card(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _filterTopupView(),
                )),
              ),
              _ListView(
                _transactionList.reversed.toList(),
                key: ValueKey(_listRebuildCount),
              ),
            ],
          ),
    );
  }

  Widget _filterTopupView() {
    final totalTransactionText = Text(
        _clientTotalTransaction == null
            ? ''
            : 'Total Transaction: ${EnVar.moneyFormat(_clientTotalTransaction)}',
      style: Theme.of(context).textTheme.subtitle1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Filter', style: Theme.of(context).textTheme.headline4,),
        const SizedBox(height: 16.0),
        FormDropdownSearch<Account>(
          label: 'Client',
          compareFn: (o1, o2) => o1?.id == o2?.id,
          onPick: _doFilter,
          showItem: (item) {
            if (item.id == -1) return 'None';
            return '${item.id} - ${item.name}';
          },
          selectedItem: () => _dummyClient,
          onFind: (query) async {
            if (_clientList == null) {
              _clientList = _transactionList
                  .map<Account>((e) => e.client).toList();
              _clientList!.insert(0, _dummyClient);
              var list = <Account>[];
              _clientList!.retainWhere((e) {
                if (list.contains(e)) return false;
                list.add(e);
                return true;
              });
            }
            if (query == null || query.isEmpty) return _clientList!;
            return _clientList!.where((element) {
              if (element.id.toString().contains(query)) return true;
              if (element.name.toLowerCase().contains(query)) return true;
              return false;
            }).toList();
          },
        ),
        const SizedBox(height: 12.0),
        LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.minWidth < 650) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(child: totalTransactionText, fit: BoxFit.scaleDown,),
                  ],
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  totalTransactionText,
                ],
              );
            }
        ),
      ],
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