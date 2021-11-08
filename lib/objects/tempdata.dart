
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/withdraw.dart';
import 'package:http/http.dart' as http;

import 'envar.dart';

class Temp {
  static double? total;
  static List<Transaction>? transactionList;
  static List<Withdraw>? withdrawList;
  static int? withdrawTotal;

  static Future<void> fillTransactionData([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        Account account = (await Account.getAccount())!;

        String url;
        if (account.status is Buyer) {
          url = '${EnVar.API_URL_HOME}/transaction?depositor=${account.mobile}';
        } else {
          url = '${EnVar.API_URL_HOME}/transaction?receiver=${account.mobile}';
        }
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body)['response'];
          final list = body['record'] as List;

          total = (body['sum'] as int).toDouble();
          if (account.status is Seller) {
            total = total!*-1;
            withdrawList = (body['withdraw'] as List).map<Withdraw>((e) => Withdraw.parse(e, account)).toList();
            withdrawTotal = body['total_withdraw'] as int;
          }
          transactionList = list.map<Transaction>((e) => Transaction.parse(e)).toList();
        }
        else {
          return fillTransactionData(++retryCount);
        }
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return fillTransactionData(++retryCount);}
  }
}