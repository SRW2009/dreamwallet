
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/transaction.dart';
import 'package:http/http.dart' as http;

import 'envar.dart';

class Temp {
  static List<Transaction>? transactionList;

  static Future<void> fillTransactionData([String? accountId, int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        final url = (accountId != null) ? '${EnVar.API_URL_HOME}/transaction/$accountId' : '${EnVar.API_URL_HOME}/transaction';
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body)['response'] as List;

          transactionList = list.map<Transaction>((e) => Transaction.parse(e)).toList();
        }
        else {
          return fillTransactionData(accountId, ++retryCount);
        }
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return fillTransactionData(accountId, ++retryCount);}
  }
}