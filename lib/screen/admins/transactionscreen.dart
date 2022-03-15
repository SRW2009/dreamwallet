
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/account/privileges/root.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/withdraw.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminTransactionScreen extends StatefulWidget {
  final Account? account;

  const AdminTransactionScreen({Key? key, this.account}) : super(key: key);

  @override
  _AdminTransactionScreenState createState() => _AdminTransactionScreenState();
}

class _AdminTransactionScreenState extends State<AdminTransactionScreen> {

  int _rebuildListCount = 0;
  int _totalMoney = 0, _totalCredit = 0, _totalDebit = 0;
  final _formKey = GlobalKey<FormState>();
  final _amountCon = TextEditingController();
  late final TextEditingController _dateCon;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime _datePicker = DateTime.now();
  late final TextEditingController _depositorCon;
  late final TextEditingController _receiverCon;
  bool _isDebitCon = false;
  late Future<List<Transaction>> _futureList;
  List<Withdraw>? _withdrawList;

  void _selectDate(DateTime? selectedDate) {
    if (selectedDate != null && selectedDate != _datePicker) {
      setState(() {
        _datePicker = selectedDate;
        _dateCon.text = _dateFormat.format(selectedDate);
      });
    }
  }

  Route<DateTime> _datePickerRoute(BuildContext context) {
    return DialogRoute(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: _datePicker,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 1),
      ),
    );
  }

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
          Uri.parse('${EnVar.API_URL_HOME}/transaction'),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            "is_debit": _isDebitCon,
            "transactionName": '-',
            "transaction_amount": amount,
            "transaction_date": _dateCon.text,
            "transaction_depositor": '62'+_depositorCon.text,
            "transaction_receiver":  _isDebitCon ? '6266630114604' : '62'+_receiverCon.text
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _amountCon.text = '';
            _dateCon.text = '';
            if (widget.account == null) _depositorCon.text = '';
            _receiverCon.text = '';
            _isDebitCon = false;

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

        final url = '${EnVar.API_URL_HOME}/transaction/delete/multiple';
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

  Future<List<Transaction>> _getList([int retryCount=0]) async {
    final account = widget.account;
    try {
      if (retryCount != 3) {
        String url;
        if (account == null) {
          url = '${EnVar.API_URL_HOME}/transactions';
        } else {
          if (account.status is Buyer) {
            url = '${EnVar.API_URL_HOME}/transaction?depositor=${account.mobile}';
          } else {
            url = '${EnVar.API_URL_HOME}/transaction?receiver=${account.mobile}';
          }
        }
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body)['response'];
          final list = data['record'] as List;

          if (widget.account != null) {
            int sum = data['sum'];
            if (widget.account!.status is Seller) {
              sum *= -1;
              final withdraws = (data['withdraw'] as List).map<Withdraw>((e) => Withdraw.parse(e, widget.account!)).toList();
              sum -= data['total_withdraw'] as int;
              setState(() {
                _withdrawList = withdraws;
              });
            }
            setState(() {
              _totalMoney = sum;
              _totalCredit = data['credit'];
              _totalDebit = data['debit'];
            });
          } else {
            setState(() {});
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
            decoration: InputDecoration(
              labelText: 'Transaction date',
              hintText: '1999-12-30',
              prefix: IconButton(
                icon: const Icon(Icons.date_range,),
                onPressed: () async {
                  var date = await Navigator.push<DateTime>(context, _datePickerRoute(context));
                  _selectDate(date);
                },
              ),
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },

          ),
          TextFormField(
            enabled: widget.account == null || (widget.account != null && widget.account!.status is! Buyer),
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
            enabled: (widget.account == null || (widget.account != null && widget.account!.status is! Seller)) && !_isDebitCon,
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
                Checkbox(value: _isDebitCon, onChanged: (widget.account == null || (widget.account != null && widget.account!.status is Buyer)) ? (val) {
                  if (val != null) {
                    setState(() {
                      _isDebitCon = val;
                    });
                  }
                } : null),
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

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _depositorCon = TextEditingController(text: (widget.account != null && widget.account!.status is Buyer) ? widget.account!.mobile.substring(2) : '');
    _receiverCon = TextEditingController(text: (widget.account != null && widget.account!.status is Seller) ? widget.account!.mobile.substring(2) : '');
    _dateCon = TextEditingController(text: _dateFormat.format(_datePicker));
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
              Text((widget.account != null) ? '${widget.account!.name}\'s Transaction (${widget.account!.status.toString()})' : 'All Transaction', style: Theme.of(context).textTheme.headline3,),
              if (widget.account != null && widget.account!.status is Buyer) Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Debit: ${EnVar.MoneyFormat(_totalDebit)}', style: Theme.of(context).textTheme.subtitle1,),
                    Text('Kredit: ${EnVar.MoneyFormat(_totalCredit)}', style: Theme.of(context).textTheme.subtitle1,),
                    Text('Total: ${EnVar.MoneyFormat(_totalMoney)}', style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
              if (widget.account != null && widget.account!.status is Seller) Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Total uang: ${EnVar.MoneyFormat(_totalMoney)}', style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
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
            future: _futureList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _ListView(
                  snapshot.data!.reversed.toList(),
                  deleteAll: _deleteAll,
                );
              }
              else if (snapshot.hasError) {
                print(snapshot.error);
                return Column(
                  children: const [
                    Text('Terjadi Kesalahan')
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            }
        ),
        if (_withdrawList != null) Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Withdraws', style: Theme.of(context).textTheme.headline3,),
              ),
              Container(color: Colors.red, height: 6.0,),
            ],
          ),
        ),
        if (_withdrawList != null) for (var o in _withdrawList!) Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o.seller_id, style: const TextStyle(
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

class _ListView extends StatefulWidget {
  final List<Transaction> list;
  final Future<void> Function(List<String> ids, [int retryCount])  deleteAll;

  const _ListView(this.list, {Key? key,
    required this.deleteAll,
  }) : super(key: key);

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
                              content: Text('Delete all with ID: ${EnVar.getAllIdsAsString(ids)} ?'),
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
                        child: Text(o.transaction_date.split('T')[0], style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),),
                      ),
                    ],
                  ),
                  Text(o.is_debit ? 'Debit' : 'Kredit', style: TextStyle(
                    color: o.is_debit ? Colors.blue : Colors.red,
                    fontSize: 12.0,
                  ),),
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
                        Text(EnVar.MoneyFormat(o.transaction_amount), style: TextStyle(
                          color: (o.is_debit) ? Colors.blue : Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: const Text('Depositor'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.depositor.name)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 4.0,),
                            Text(o.depositor.mobile)
                          ],
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text('Receiver'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 4.0,),
                            Text(o.receiver.name)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 4.0,),
                            Text(o.receiver.mobile)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}