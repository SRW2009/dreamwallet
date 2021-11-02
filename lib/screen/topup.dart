
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:flutter/material.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({Key? key}) : super(key: key);

  @override
  _TopupScreenState createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {

  Widget _listView(List<Transaction> list) {
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
          child: Text('My Transaction', style: Theme.of(context).textTheme.headline3,),
        )),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _listView(Temp.transactionList!),
          ),
        ),
      ],
    );
  }
}
