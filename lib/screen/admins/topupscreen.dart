
import 'dart:async';

import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';

class AdminTopupScreen extends StatefulWidget {
  final Function() reload;

  const AdminTopupScreen({Key? key, required this.reload}) : super(key: key);

  @override
  _AdminTopupScreenState createState() => _AdminTopupScreenState();
}

class _AdminTopupScreenState extends State<AdminTopupScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _clientCon;
  final _amountCon = TextEditingController();
  late List<Topup> _topupList;
  List<Account>? _clientList;

  Future<void> _createTopup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading...')));

    int clientId = _clientCon!.id;
    double amount = double.tryParse(_amountCon.text)!;

    final statusCode = await Request().adminTopup(amount, clientId);
    if (statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      widget.reload();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed')));
    }
  }

  Future<void> _verifyTopups(List<int> ids) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading...')));

    final statusCode = await Request().adminVerifyTopups(ids);
    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      widget.reload();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed')));
    }
  }

  Widget _createTopupView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add', style: Theme.of(context).textTheme.headline4,),
          const SizedBox(height: 16.0),
          FormDropdownSearch<Account>(
            label: 'Client',
            compareFn: (o1, o2) => o1?.id == o2?.id,
            onPick: (item) {
              setState(() {
                _clientCon = item;
              });
            },
            showItem: (item) => '${item.id} - ${item.name}',
            onFind: (query) async {
              _clientList ??= await Request().adminGetAccounts();
              if (query == null || query.isEmpty) return _clientList!;
              return _clientList!.where((element) {
                if (element.id.toString().contains(query)) return true;
                if (element.name.toLowerCase().contains(query)) return true;
                return false;
              }).toList();
            },
          ),
          TextFormField(
            controller: _amountCon,
            decoration: const InputDecoration(
              labelText: 'Topup amount',
              prefixText: 'IDR ',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              int? value = int.tryParse(_amountCon.text);
              if (value == null) return 'Only input numbers in this field.';
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: MyButtonStyle.primaryElevatedButtonStyle(context),
            child: const Text('Create Topup'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createTopup();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _listView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, i) {
          final o = _topupList[i];
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
        childCount: _topupList.length,
      ),
    );
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _topupList = Temp.topupList!;
    super.initState();
  }

  void selectAll() {
    setState(() {
      _topupList = _topupList.map<Topup>((e) => e..selected = true).toList();
    });
  }

  void unselectAll() {
    setState(() {
      _topupList = _topupList.map<Topup>((e) => e..selected = false).toList();
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
                  Text('All Topup Record', style: Theme.of(context).textTheme.headline3,),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text('Total Topup: ${EnVar.moneyFormat(Temp.topupTotal!)}', style: Theme.of(context).textTheme.subtitle1,),
                  ),
                ],
              ),
            )),
          ),
          SliverToBoxAdapter(
            child: Card(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _createTopupView(),
            )),
          ),
          SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextButton(
                      onPressed: selectAll,
                      child: const Text('Select All'),
                      style: MyButtonStyle.primaryTextButtonStyle(context),
                    ),
                    const SizedBox(width: 12.0,),
                    TextButton(
                      onPressed: unselectAll,
                      child: const Text('Unselect All'),
                      style: MyButtonStyle.primaryTextButtonStyle(context),
                    ),
                    const SizedBox(width: 12.0,),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: MyButtonStyle.primaryElevatedButtonStyle(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Verify all selected'),
                        onPressed: (_topupList.any((e) => e.selected)) ? () async {
                          final ids = _topupList
                              .where((e) => e.selected && !e.verifiedByAdmin())
                              .map<int>((e) => e.id).toList();

                          final isVerify = await Navigator.push<bool>(context,
                              DialogRoute(context: context, builder: (c) => AlertDialog(
                                contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Verify all with ID: ${ids.join(', ')} ?'),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      '*If those you pick doesn\'t appear in here, then it\'s already verified.',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    if (ids.isEmpty) Text(
                                      'Every topup you pick is already verified!',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () {return Navigator.pop(c, false);}, child: const Text('No')),
                                  TextButton(onPressed: (ids.isEmpty) ? null : () {return Navigator.pop(c, true);}, child: const Text('Yes')),
                                ],
                              )));

                          if (isVerify != null && isVerify) {
                            _verifyTopups(ids);
                          }
                        } : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _listView(),
        ],
      ),
    );
  }
}