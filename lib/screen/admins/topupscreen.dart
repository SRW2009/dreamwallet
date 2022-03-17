
import 'dart:async';

import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/screen/admin.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';

class AdminTopupScreen extends StatefulWidget {
  const AdminTopupScreen({Key? key}) : super(key: key);

  @override
  _AdminTopupScreenState createState() => _AdminTopupScreenState();
}

class _AdminTopupScreenState extends State<AdminTopupScreen> {

  final _rootKey = GlobalKey<AdminPageState>();
  final _formKey = GlobalKey<FormState>();
  final _clientIdCon = TextEditingController();
  final _amountCon = TextEditingController();
  late List<Topup> _topupList;

  Future<void> _createTopup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading...')));

    int clientId = int.tryParse(_clientIdCon.text)!;
    double amount = double.tryParse(_amountCon.text)!;

    final statusCode = await Request().adminTopup(amount, clientId);
    if (statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      _rootKey.currentState!.reload();
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
    if (statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')));

      _rootKey.currentState!.reload();
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
          TextFormField(
            controller: _clientIdCon,
            decoration: const InputDecoration(
              labelText: 'Client ID',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              int? value = int.tryParse(_amountCon.text);
              if (value == null) return 'Only input numbers in this field.';
              return null;
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
                        onPressed: (_topupList.isNotEmpty && _topupList.isNotEmpty) ? () async {
                          final ids = _topupList
                              .where((e) => e.admin == null)
                              .map<int>((e) => e.id).toList();

                          final isVerify = await Navigator.push<bool>(context,
                              DialogRoute(context: context, builder: (c) => AlertDialog(
                                content: Text('Verify all with ID: ${ids.join(', ')} ?'),
                                actions: [
                                  TextButton(onPressed: () {return Navigator.pop(c, false);}, child: const Text('No')),
                                  TextButton(onPressed: () {return Navigator.pop(c, true);}, child: const Text('Yes')),
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
          _ListView(
            _topupList,
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatefulWidget {
  final List<Topup> list;

  const _ListView(this.list, {Key? key}) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  late List<Topup> _filteredList;

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