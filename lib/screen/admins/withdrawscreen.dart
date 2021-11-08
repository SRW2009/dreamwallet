
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/withdraw.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminWithdrawScreen extends StatefulWidget {
  final Account? account;

  const AdminWithdrawScreen({Key? key, this.account}) : super(key: key);

  @override
  _AdminWithdrawScreenState createState() => _AdminWithdrawScreenState();
}

class _AdminWithdrawScreenState extends State<AdminWithdrawScreen> {

  int _rebuildListCount = 0;
  int _totalWithdraw = 0;
  int _maxWithdraw = 0;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sellerIdCon;
  final _amountCon = TextEditingController();
  late Future<List<Withdraw>> _futureList;

  Future<void> _add([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        int amount;
        try {
          amount = int.parse(_amountCon.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to parse amount or date!')));

          return;
        }
        final response = await http.post(
          Uri.parse('${EnVar.API_URL_HOME}/withdraw'),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            "amount": amount,
            "seller_id": '62'+_sellerIdCon.text,
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _amountCon.text = '';

            _futureList = _getList();
            _rebuildListCount++;
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_add(++retryCount);}
  }

  Future<void> _deleteAll(List<String> ids, [int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        final url = '${EnVar.API_URL_HOME}/withdraw/delete/multiple';
        final response = await http.post(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            'id': ids
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _futureList = _getList();
            _rebuildListCount++;
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_deleteAll(ids, ++retryCount);}
  }

  Future<List<Withdraw>> _getList([int retryCount=0]) async {
    final account = widget.account;
    try {
      if (retryCount != 3) {
        String url;
        if (account != null) {
          url = '${EnVar.API_URL_HOME}/transaction?receiver=${account.mobile}';
        } else {
          url = '${EnVar.API_URL_HOME}/withdraw';
        }
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body)['response'];
          List list;
          if (account != null) {
            list = data['withdraw'] as List;
          } else {
            list = data['record'] as List;
          }

          setState(() {
            _totalWithdraw = data['total_withdraw'];
            if (account != null) {
              int sum = data['sum'];
              if (sum == 0) {
                _maxWithdraw = 0;
              } else {
                _maxWithdraw = ((data['sum'] as int) * -1) - _totalWithdraw;
              }
            }
          });

          return list.map<Withdraw>((e) => Withdraw.parse(e, account)).toList();
        }

        return _getList(++retryCount);
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return _getList(++retryCount);}
  }

  Widget _addOrUpdateView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add', style: Theme.of(context).textTheme.headline4,),
          const SizedBox(height: 16.0),
          TextFormField(
            enabled: false,
            controller: _sellerIdCon,
            keyboardType: TextInputType.phone,
            maxLength: 14,
            decoration: const InputDecoration(
              labelText: 'Seller',
              prefixText: '+62 ',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            controller: _amountCon,
            decoration: InputDecoration(
              labelText: 'Withdraw amount',
              prefixText: 'IDR ',
              hintText: 'Max withdraw amount: '+EnVar.MoneyFormat(_maxWithdraw),
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              int? value = int.tryParse(_amountCon.text);
              if (value == null) return 'Only input numbers in this field.';
              if (value > _maxWithdraw) return 'Amount can\'t be greater than max withdraw!';
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: MyButtonStyle.primaryElevatedButtonStyle(context),
            child: const Text('Add'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _add();
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
    _sellerIdCon = TextEditingController(text: widget.account?.mobile.substring(2) ?? '');
    _futureList = _getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((widget.account != null) ? '${widget.account!.name}\'s Withdraw Record' : ' All Withdraw Record', style: Theme.of(context).textTheme.headline3,),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text('Total Withdraw: ${EnVar.MoneyFormat(_totalWithdraw)}', style: Theme.of(context).textTheme.subtitle1,),
              ),
            ],
          ),
        )),
        if (widget.account != null) Card(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _addOrUpdateView(),
        )),
        FutureBuilder<List<Withdraw>>(
            key: ValueKey(_rebuildListCount),
            future: _futureList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _ListView(
                  snapshot.data!,
                  deleteAll: _deleteAll,
                );
              }
              else if (snapshot.hasError) {
                return Column(
                  children: const [
                    Text('Terjadi Kesalahan')
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            }
        ),
      ],
    );
  }
}

class _ListView extends StatefulWidget {
  final List<Withdraw> list;
  final Future<void> Function(List<String> ids, [int retryCount])  deleteAll;

  const _ListView(this.list, {Key? key,
    required this.deleteAll,
  }) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  late List<Withdraw> _filteredList;

  String _getAllIdsAsString(List<String> ids) {
    String content = ids.first;
    for (var i = 1; i < ids.length; ++i) {
      final o = ids[i];
      content += ', $o';
    }
    return content;
  }

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
    final selectedList = _filteredList.where((element) => element.selected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
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
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete all selected'),
                    onPressed: (_filteredList.isNotEmpty && selectedList.isNotEmpty) ? () async {
                      final ids = selectedList.map<String>((e) => e.id.toString()).toList();

                      final isDelete = await Navigator.push<bool>(context,
                          DialogRoute(context: context, builder: (c) => AlertDialog(
                            content: Text('Delete all with ID: ${_getAllIdsAsString(ids)} ?'),
                            actions: [
                              TextButton(onPressed: () {return Navigator.pop(c, false);}, child: const Text('No')),
                              TextButton(onPressed: () {return Navigator.pop(c, true);}, child: const Text('Yes')),
                            ],
                          )));

                      if (isDelete != null && isDelete) {
                        widget.deleteAll(ids);
                      }
                    } : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var o in _filteredList)
          Card(
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
                        child: Text(o.seller_id, style: const TextStyle(
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
                        Text(o.seller.name, style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(height: 6.0,),
                        Text(EnVar.MoneyFormat(o.amount), style: const TextStyle(
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
    );
  }
}