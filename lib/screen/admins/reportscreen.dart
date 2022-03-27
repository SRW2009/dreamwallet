
import 'dart:async';

import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/account/privileges/root.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class _LoadingValue {
  int progress;
  int max;

  double getPercentage() => progress/max;

  _LoadingValue(this.progress, this.max);
}

class _Report {
  String accountName;
  int accountId;
  AccountPrivilege accountStatus;
  int accountCredit;
  int accountDebit;
  int accountSum;
  List<Transaction> accountTransactions;
  List<Topup>? accountTopups;

  _Report(this.accountId, this.accountName, this.accountStatus,
      this.accountCredit, this.accountDebit, this.accountSum, this.accountTransactions,
      {this.accountTopups});
}

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({Key? key}) : super(key: key);

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  static const _topupFromTransferAmount = [ 200000, 400000, 700000 ];
  bool _isLoading = false;
  final ValueNotifier<int> _loadStep = ValueNotifier(0);
  final ValueNotifier<_LoadingValue> _accountsLoadProgress = ValueNotifier(_LoadingValue(0, 0));
  List<_Report>? _reports;

  Future<List<Account>> _getAccountList() async {
    final _accountList = <Account>[];
    for (var o in Temp.topupList!) {
      if (o.cashier != null) _accountList.add(o.cashier!);
      if (o.admin != null) _accountList.add(o.admin!);
    }
    for (var o in Temp.transactionList!) {
      _accountList.add(o.client);
      _accountList.add(o.merchant);
    }
    for (var o in Temp.withdrawList!) {
      _accountList.add(o.merchant);
      _accountList.add(o.admin);
    }
    var list = <Account>[];
    _accountList.retainWhere((e) {
      if (list.contains(e)) return false;
      list.add(e);
      return true;
    });
    return list;
  }

  Future<_Report> _getAccountReport(Account account) async {
    int totalDebit = 0;
    int totalCredit = 0;
    int? totalSaldo;
    final transactionList = <Transaction>[];
    List<Topup>? topupList;

    if (account.status is Buyer) {
      for (var o in Temp.topupList!) {
        if (o.client == account) {
          topupList ??= [];
          topupList.add(o);
          totalDebit += o.total.toInt();
        }
      }
      for (var o in Temp.transactionList!) {
        if (o.client == account) {
          totalCredit += o.total.toInt();
          transactionList.add(o);
        }
      }
    }
    if (account.status is Seller) {
      for (var o in Temp.transactionList!) {
        if (o.merchant == account) {
          totalDebit += o.total.toInt();
          transactionList.add(o);
        }
      }
      for (var o in Temp.withdrawList!) {
        if (o.merchant == account) {
          totalCredit += o.total.toInt();
        }
      }
    }
    if (account.status is Cashier) {
      for (var o in Temp.topupList!) {
        if (o.cashier == account) {
          topupList ??= [];
          topupList.add(o);

          if (o.verifiedByAdmin()) {
            totalCredit += o.total.toInt();
          } else {
            totalDebit += o.total.toInt();
          }
        }
      }
      totalSaldo = totalDebit + totalCredit;
    }
    if (account.status is Admin) {
      for (var o in Temp.topupList!) {
        if (o.admin == account) {
          topupList ??= [];
          topupList.add(o);
          totalDebit += o.total.toInt();
        }
      }
      for (var o in Temp.withdrawList!) {
        if (o.admin == account) {
          totalCredit += o.total.toInt();
        }
      }
    }

    totalSaldo ??= totalDebit - totalCredit;
    return _Report(account.id,account.name,  account.status, totalCredit, totalDebit, totalSaldo, transactionList, accountTopups: topupList);
  }

  Stream<_LoadingValue> _getReports(List<Account> accounts) async* {
    for (var i = 0; i < accounts.length; ++i) {
      var account = accounts[i];
      var report = await _getAccountReport(account);
      _reports!.add(report);
      yield _LoadingValue(i+1, accounts.length);
    }
  }

  Future _getReport() async {
    setState(() {
      _isLoading = true;
    });

    List<Account> accounts = await _getAccountList();
    _loadStep.value = 1;
    _accountsLoadProgress.value = _LoadingValue(0, accounts.length);
    _reports = [];

    var reports = _getReports(accounts);
    await for (final value in reports) {
      _accountsLoadProgress.value = value;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _downloadReport() {
    final data = ['Dreampay Report\n'];

    data.add('\nBuyer:\n');
    /// {'buyer1' : [transaction1, transaction2], }
    final Map<String, List<Topup>> pastEventTopups = {};
    for (var o in _reports!.where((element) => element.accountStatus is Buyer).toList()) {
      data.add('- (${o.accountId}) ${o.accountName}:\n'
          '  Total Topup = ${EnVar.moneyFormat(o.accountDebit)};\n'
          '  Total Transaksi = ${EnVar.moneyFormat(o.accountCredit)};\n'
          '  Saldo = ${EnVar.moneyFormat(o.accountSum)};\n\n');

      // Past Event Topups
      for (var topup in o.accountTopups!) {
        pastEventTopups[o.accountName] ??= [];
        if (!_topupFromTransferAmount.contains(topup.total.toInt())) {
          pastEventTopups[o.accountName]!.add(topup);
        }
      }
    }

    data.add('\nSeller:\n');
    /// {'seller1' : {
    ///   'depositor1': [
    ///     [transaction1, transaction2],
    ///     [transaction3, transaction4],
    ///   ]
    /// }}
    final Map<String, Map<String, List<List<Transaction>>>> possibleDuplicateTransactions = {};
    for (var o in _reports!.where((element) => element.accountStatus is Seller).toList()) {
      data.add('- (${o.accountId}) ${o.accountName}:\n'
          '  Total Transaksi = ${EnVar.moneyFormat(o.accountDebit)};\n'
          '  Total Withdraw = ${EnVar.moneyFormat(o.accountCredit)};\n'
          '  Saldo = ${EnVar.moneyFormat(o.accountSum)};\n\n');

      // Duplicate Transactions
      for (var transaction in Temp.transactionList!) {
        final duplicates = o.accountTransactions.where(
                (element) => element.client == transaction.client
                    && element.merchant == transaction.merchant
                    && element.total == transaction.total
        ).toList();

        if (duplicates.length > 1) {
          possibleDuplicateTransactions[o.accountName] ??= {};
          possibleDuplicateTransactions[o.accountName]![transaction.client.name] ??= [];

          if (!possibleDuplicateTransactions[o.accountName]![transaction.client.name]!.any(
                  (element) => element.any(
                          (element2) => element2.id == transaction.id))) {
            possibleDuplicateTransactions[o.accountName]![transaction.client.name]!.add(duplicates);
          }
        }
      }
    }

    data.add('\nCashier:\n');
    for (var o in _reports!.where((element) => element.accountStatus is Cashier).toList()) {
      data.add('- (${o.accountId}) ${o.accountName}:\n'
          '  Total Money On Hand = ${EnVar.moneyFormat(o.accountDebit)};\n'
          '  Total Money Reported = ${EnVar.moneyFormat(o.accountCredit)};\n'
          '  Total Topup = ${EnVar.moneyFormat(o.accountSum)};\n');

      if (o.accountTopups != null) {
        data.add('  Topup List:\n');
        for (var o in o.accountTopups!) {
          data.add('  - ${o.created_at.split('T')[1].split('.')[0]}: ${o.client.name} -> ${EnVar.moneyFormat(o.total)}\n');
        }
      }

      data.add('\n');
    }

    data.add('\nAdmin:\n');
    for (var o in _reports!.where((element) => element.accountStatus is Admin).toList()) {
      data.add('- (${o.accountId}) ${o.accountName}:\n'
          '  Total Topup = ${EnVar.moneyFormat(o.accountDebit)};\n'
          '  Total Withdrawal = ${EnVar.moneyFormat(o.accountCredit)};\n'
      );

      if (o.accountTopups != null) {
        data.add('  Topup List:\n');
        for (var o in o.accountTopups!) {
          data.add('  - ${o.created_at.split('T')[1].split('.')[0]}: ${o.client.name} -> ${EnVar.moneyFormat(o.total)}\n');
        }
      }

      data.add('\n');
    }

    data.add('\nPossible Duplicate Transactions:\n');
    for (var o in possibleDuplicateTransactions.entries) {
      data.add('- ${o.key}:\n');
      for (var o1 in o.value.entries) {
        data.add('  - ${o1.key}:\n');

        for (var i = 0; i < o1.value.length; ++i) {
          var o2 = o1.value[i];

          final ids = o2.map<String>((e) => e.id.toString()).toList();
          data.add('    ${i+1}. No. Note -> ${EnVar.getAllIdsAsString(ids)}: Amount = ${EnVar.moneyFormat(o2[0].total)};\n');
        }
      }
      data.add('\n');
    }

    data.add('\nPossible topup from past event:\n');
    for (var o in pastEventTopups.entries) {
      if (pastEventTopups[o.key]!.isEmpty) continue;

      data.add('- ${o.key}:\n');
      for (var i = 0; i < pastEventTopups[o.key]!.length; ++i) {
        var o1 = pastEventTopups[o.key]![i];

        data.add('  ${i+1}. No. Note -> ${o1.id}: Amount = ${EnVar.moneyFormat(o1.total)};\n');
      }
      data.add('\n');
    }

    if (foundation.kIsWeb) {
      var blob = html.Blob(data, 'text/plain', 'native');

      html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob).toString(),
      )..setAttribute("download", "dreampay report.txt")..click();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                child: ValueListenableBuilder<int>(
                  valueListenable: _loadStep,
                  builder: (context, step, child) => Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLoading && _reports == null)
                      Column(
                        children: [
                          ElevatedButton(
                            child: const Text('Get Report'),
                            style: MyButtonStyle.primaryElevatedButtonStyle(context),
                            onPressed: () {
                              _getReport();
                            },
                          ),
                          const SizedBox(height: 14.0,),
                          const Text('This process might take longer than expected.', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                        ],
                      ),
                    if (!_isLoading && _reports != null)
                      Column(
                        children: [
                          ElevatedButton(
                            child: const Text('Download Report'),
                            style: MyButtonStyle.primaryElevatedButtonStyle(context),
                            onPressed: () {
                              _downloadReport();
                            },
                          ),
                          const SizedBox(height: 14.0,),
                          const Text('Report loaded and ready to download.', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                        ],
                      ),
                    if (_isLoading && step == 0) Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 14.0,),
                        Text('Getting all account...', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                      ],
                    ),
                    if (_isLoading && step == 1) ValueListenableBuilder<_LoadingValue>(
                      valueListenable: _accountsLoadProgress,
                      builder: (context, progress, child) {
                        return Column(
                          children: [
                            CircularProgressIndicator(
                              value: progress.getPercentage(),
                            ),
                            const SizedBox(height: 14.0,),
                            Text('Loaded ${progress.progress} of ${progress.max} accounts...', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        );
  }
}
