
import 'dart:async';

import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/withdraw.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/screen/admin.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';

class AdminWithdrawScreen extends StatefulWidget {
  final Function() reload;

  const AdminWithdrawScreen({Key? key, required this.reload}) : super(key: key);

  @override
  _AdminWithdrawScreenState createState() => _AdminWithdrawScreenState();
}

class _AdminWithdrawScreenState extends State<AdminWithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _merchantCon;
  final _amountCon = TextEditingController();
  late List<Withdraw> _withdrawList;
  List<Account>? _merchantList;

  Future<void> _createWithdrawal() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading...')));

    int merchantId = _merchantCon!.id;
    double amount = double.tryParse(_amountCon.text)!;

    final statusCode = await Request().adminCreateWithdrawal(merchantId, amount);
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

  Widget _addOrUpdateView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add', style: Theme.of(context).textTheme.headline4,),
          const SizedBox(height: 16.0),
          FormDropdownSearch<Account>(
            label: 'Merchant',
            compareFn: (o1, o2) => o1?.id == o2?.id,
            onPick: (item) {
              setState(() {
                _merchantCon = item;
              });
            },
            showItem: (item) => '${item.id} - ${item.name}',
            onFind: (query) async {
              _merchantList ??= await Request().adminGetMerchants();
              if (query == null || query.isEmpty) return _merchantList!;
              return _merchantList!.where((element) {
                if (element.id.toString().contains(query)) return true;
                if (element.name.toLowerCase().contains(query)) return true;
                return false;
              }).toList();
            },
          ),
          TextFormField(
            controller: _amountCon,
            decoration: const InputDecoration(
              labelText: 'Withdraw amount',
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
            child: const Text('Create Withdrawal'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createWithdrawal();
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
    _withdrawList = Temp.withdrawList!;
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
                  Text('All Withdraw Record', style: Theme.of(context).textTheme.headline3,),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text('Total Withdrawn: ${EnVar.moneyFormat(Temp.withdrawTotal!)}', style: Theme.of(context).textTheme.subtitle1,),
                  ),
                ],
              ),
            )),
          ),
          SliverToBoxAdapter(
            child: Card(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _addOrUpdateView(),
            )),
          ),
          _ListView(
            _withdrawList,
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatefulWidget {
  final List<Withdraw> list;

  const _ListView(this.list, {Key? key}) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  late List<Withdraw> _filteredList;

  void selectAll() {
    setState(() {
      _filteredList = _filteredList.map<Withdraw>((e) => e..selected = true).toList();
    });
  }

  void unselectAll() {
    setState(() {
      _filteredList = _filteredList.map<Withdraw>((e) => e..selected = false).toList();
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.merchant.name, style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(height: 6.0,),
                        Text(EnVar.moneyFormat(o.total), style: const TextStyle(
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
          );
        },
        childCount: _filteredList.length,
      ),
    );
  }
}