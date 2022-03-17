
import 'dart:async';

import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/withdraw.dart';

import 'account/privileges/root.dart';

class Temp {
  static List<Transaction>? transactionList;
  static double? transactionTotal;
  static List<Withdraw>? withdrawList;
  static double? withdrawTotal;
  static List<Topup>? topupList;
  static double? topupTotal;
  static double? cashierMoneyOnHand;
  static double? cashierMoneyReported;

  static Future<void> fillTransactionData() async {
    try {
      final account = (await Account.getAccount())!;

      if (account.status is Buyer) {
        transactionList = await Request().clientGetTransactions();
      }
      if (account.status is Seller) {
        transactionList = await Request().merchantGetTransactions();
      }
      if (account.status is Admin) {
        transactionList = await Request().adminGetTransactions();
      }
      transactionTotal = transactionList
          ?.fold<double>(0, (previousValue, element) => previousValue+element.total);
      transactionTotal = transactionTotal! - (withdrawTotal ?? 0);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> fillWithdrawData() async {
    try {
      final account = (await Account.getAccount())!;

      if (account.status is Seller) {
        withdrawList = await Request().merchantGetWithdrawals();
      }
      if (account.status is Admin) {
        withdrawList = await Request().adminGetWithdrawals();
      }
      withdrawTotal = withdrawList
          ?.fold<double>(0, (previousValue, element) => previousValue+element.total);
      transactionTotal =  (transactionTotal ?? 0) - withdrawTotal!;
    } catch (e) {
      print(e);
    }
  }

  static Future<void> fillTopupData() async {
    try {
      final account = (await Account.getAccount())!;

      if (account.status is Cashier) {
        topupList = await Request().cashierGetTopups();
      }
      if (account.status is Admin) {
        topupList = await Request().adminGetTopups(null);
      }
      topupTotal = topupList
          ?.fold<double>(0, (previousValue, element) => previousValue+element.total);

      double moneyOnHand = 0.0, moneyReported = 0.0;
      for (var element in topupList!) {
        // if admin is null, then this topup is not reported yet
        if (element.admin == null) {
          moneyOnHand += element.total;
        } else {
          moneyReported += element.total;
        }
      }
      cashierMoneyOnHand = moneyOnHand;
      cashierMoneyReported = moneyReported;
    } catch (e) {
      print(e);
    }
  }
}