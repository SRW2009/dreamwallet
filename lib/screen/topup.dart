
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /*Row(
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
          ),*/
        for (var o in list)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.transaction_date.toIso8601String().split('T')[0], style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),),
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
                  Text(o.transaction_receiver, style: const TextStyle(
                    color: Colors.deepOrange,
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
        Card(child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Transactions', style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                  const SizedBox(height: 16.0,),
                  Text('My Wallet: IDR ${Temp.total!}', style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14.0,
                    //fontWeight: FontWeight.w500,
                  ),),
                ],
              ),
            ),
            Container(color: Colors.blue, height: 6.0,),
          ],
        )),
        _listView(Temp.transactionList!),
      ],
    );
  }
}
