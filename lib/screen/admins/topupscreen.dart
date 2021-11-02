
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminTopupScreen extends StatefulWidget {
  final String? accountId;

  const AdminTopupScreen({Key? key, this.accountId}) : super(key: key);

  @override
  _AdminTopupScreenState createState() => _AdminTopupScreenState();
}

class _AdminTopupScreenState extends State<AdminTopupScreen> {

  int _rebuildListCount = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameCon = TextEditingController();
  final _amountCon = TextEditingController();
  final _dateCon = TextEditingController();
  final _depositorCon = TextEditingController();
  final _receiverCon = TextEditingController();
  bool _isDebitCon = false;

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

        double amount;
        DateTime date;
        try {
          amount = double.parse(_amountCon.text);
          date = DateTime.parse(_dateCon.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to parse amount or date!')));

          return;
        }
        final response = await http.post(
          Uri.parse('${EnVar.API_URL_HOME}/transaction'),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            "is_debit": _isDebitCon,
            "transactionName": _nameCon.text,
            "transaction_amount": amount,
            "transaction_date": date.toIso8601String().split('T')[0],
            "transaction_depositor": '62'+_depositorCon.text,
            "transaction_receiver":  _isDebitCon ? '' : '62'+_receiverCon.text
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _nameCon.text = '';
            _amountCon.text = '';
            _dateCon.text = '';
            _depositorCon.text = '';
            _receiverCon.text = '';
            _isDebitCon = false;

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

  /*Future<void> _update([int retryCount=0, Transaction? transaction]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        String url;
        http.Response response;
        if (account != null) {
          url = '${EnVar.API_URL_HOME}/update/${account.mobile}';
          response = await http.post(
            Uri.parse(url),
            headers: EnVar.HTTP_HEADERS(),
            body: jsonEncode({
              //"account_mobile": account.mobile,
              "account_name": account.name,
              "account_status": account.status.toChar(),
              "is_active": account.isActive,
            }),
          );
        }
        else {
          url = '${EnVar.API_URL_HOME}/update/$_updateId';
          response = await http.post(
            Uri.parse(url),
            headers: EnVar.HTTP_HEADERS(),
            body: jsonEncode({
              "account_mobile": _mobileCon.text,
              "account_name": _nameCon.text,
              "account_status": AccountPrivilege.parseInt(_statusCon)!.toChar(),
            }),
          );
        }

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _updateId = null;
            _nameCon.text = '';
            _mobileCon.text = '';
            _statusCon = 0;

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

    } on TimeoutException {_update(++retryCount, account);}
  }

  Future<void> _delete(String id, [int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        final url = '${EnVar.API_URL_HOME}/delete/$id';
        final response = await http.post(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
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

    } on TimeoutException {_delete(id, ++retryCount);}
  }*/

  Future<List<Transaction>> _getList([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        final url = (widget.accountId != null) ? '${EnVar.API_URL_HOME}/transaction/${widget.accountId}' : '${EnVar.API_URL_HOME}/transaction';
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body)['response'] as List;

          return list.map<Transaction>((e) => Transaction.parse(e)).toList();
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
            controller: _nameCon,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            controller: _amountCon,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'IDR ',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            controller: _dateCon,
            decoration: const InputDecoration(
              labelText: 'Date',
              hintText: '1999-12-30',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            controller: _depositorCon,
            keyboardType: TextInputType.phone,
            maxLength: 14,
            decoration: const InputDecoration(
              labelText: 'Depositor',
              prefixText: '+62 ',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            enabled: !_isDebitCon,
            controller: _receiverCon,
            keyboardType: TextInputType.phone,
            maxLength: 14,
            decoration: const InputDecoration(
              labelText: 'Receiver',
              prefixText: '+62 ',
            ),
            validator: (e) {
              if (!_isDebitCon) if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(value: _isDebitCon, onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _isDebitCon = val;
                    });
                  }
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text('Is Debit', style: Theme.of(context).textTheme.bodyText2,),
                ),
              ],
            ),
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

  /*Widget _listView(List<Transaction> list) {
    int nameFlex = 1;
    int amountFlex = 1;
    int dateFlex = 1;
    int depositorFlex = 1;
    int receiverFlex = 1;
    int isDebitFlex = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: nameFlex, child: Text('Name', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: amountFlex, child: Text('Amount', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: dateFlex, child: Text('Date', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: depositorFlex, child: Text('Depositor', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: receiverFlex, child: Text('Receiver', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: isDebitFlex, child: Text('Is Debit', style: Theme.of(context).textTheme.headline6,)),
          ],
        ),
        const Divider(height: 24.0, thickness: 1.0, color: Colors.black,),
        for (var o in list)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: nameFlex, child: Text(o.transactionName, style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: amountFlex, child: Text('IDR ${o.transaction_amount}', style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: dateFlex, child: Text(o.transaction_date.toIso8601String().split('T')[0], style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: depositorFlex, child: Text(o.transaction_depositor, style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: receiverFlex, child: Text(o.transaction_receiver, style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: isDebitFlex, child: Row(
                    children: [
                      Checkbox(value: o.is_debit, onChanged: null),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text('${o.is_debit}', style: Theme.of(context).textTheme.bodyText2,),
                      ),
                    ],
                  )),
                ],
              ),
              const Divider(thickness: 1.0,),
            ],
          ),
      ],
    );
  }*/

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
                      Text(o.transaction_date.toIso8601String().split('T')[0], style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),),
                      Text(o.is_debit ? 'Debit' : 'Kredit', style: TextStyle(
                        color: o.is_debit ? Colors.blue : Colors.red,
                        fontSize: 12.0,
                      ),),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.transactionName, style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),),
                        const SizedBox(height: 4.0,),
                        Text('IDR ${o.transaction_amount}', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),),
                      ],
                    ),
                  ),
                  Text('Depositor: '+o.transaction_depositor, style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 14.0,
                  ),),
                  const SizedBox(height: 2.0,),
                  Text('Receiver: '+o.transaction_receiver, style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 14.0,
                  ),),
                ],
              ),
            ),
          ),
      ],
    );
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
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
          child: Text((widget.accountId != null) ? '${widget.accountId}\'s Transaction' : 'All Transaction', style: Theme.of(context).textTheme.headline3,),
        )),
        Card(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _addOrUpdateView(),
        )),
        FutureBuilder<List<Transaction>>(
            key: ValueKey(_rebuildListCount),
            future: _getList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _listView(snapshot.data!);
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
