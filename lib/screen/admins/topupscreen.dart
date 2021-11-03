
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
  int _totalMoney = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameCon = TextEditingController();
  final _amountCon = TextEditingController();
  final _dateCon = TextEditingController();
  late final TextEditingController _depositorCon;
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

        int amount;
        DateTime date;
        try {
          amount = int.parse(_amountCon.text);
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
            if (widget.accountId == null) _depositorCon.text = '';
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
          final data = jsonDecode(response.body);
          final list = data['response'] as List;

          if (widget.accountId != null) {
            setState(() {
              _totalMoney = data['sum'];
            });
          }

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
              labelText: 'Transaction name',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            controller: _amountCon,
            decoration: const InputDecoration(
              labelText: 'Transaction amount',
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
              labelText: 'Transaction date',
              hintText: '1999-12-30',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            enabled: widget.accountId == null,
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
                      Text(o.transaction_date.split('T')[0], style: const TextStyle(
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
                  if (!o.is_debit) Text('Receiver: '+o.transaction_receiver, style: TextStyle(
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
    _depositorCon = TextEditingController(text: widget.accountId?.substring(2) ?? '');
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
              Text((widget.accountId != null) ? '${widget.accountId}\'s Transaction' : 'All Transaction', style: Theme.of(context).textTheme.headline3,),
              if (widget.accountId != null) Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text('Total: IDR $_totalMoney', style: Theme.of(context).textTheme.subtitle1,),
              ),
            ],
          ),
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
