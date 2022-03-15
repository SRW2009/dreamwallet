
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class _LoadingValue {
  int progress;
  int max;

  double getPercentage() => progress/max;

  _LoadingValue(this.progress, this.max);
}

class _Report {
  String accountName;
  String accountMobile;
  AccountPrivilege accountStatus;
  int accountCredit;
  int accountDebit;
  int accountSum;
  int? accountTopup;
  List<Transaction> accountTransactions;

  _Report(this.accountName, this.accountMobile, this.accountStatus,
      this.accountCredit, this.accountDebit, this.accountSum, this.accountTransactions);
}

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({Key? key}) : super(key: key);

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {

  bool _isTimeout = false;
  bool _isLoading = false;
  final ValueNotifier<int> _loadStep = ValueNotifier(0);
  final ValueNotifier<_LoadingValue> _accountsLoadProgress = ValueNotifier(_LoadingValue(0, 0));
  List<_Report>? _reports;

  Future<List<Account>> _getAccountList([int retryCount=0]) async {
    if (retryCount != 3) {
      const url = '${EnVar.API_URL_HOME}/account';
      final response = await http.get(
        Uri.parse(url),
        headers: EnVar.HTTP_HEADERS(),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body)['response'] as List;

        return list.map<Account>((e) => Account.parse(e)).toList();
      }

      return _getAccountList(++retryCount);
    }
    else {
      throw TimeoutException('Timeout');
    }
  }

  Future<_Report> _getAccountReport(Account account, [int retryCount=0]) async {
    try {
      if (retryCount != 3) {
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
          final data = jsonDecode(response.body)['response'];

          int sum = data['sum'];
          sum -= data['total_withdraw'] as int;
          int totalMoney = sum;
          int totalCredit = data['credit'];
          int totalDebit = data['debit'];

          List<Transaction> list = (data['record'] as List).map<Transaction>((e) => Transaction.parse(e)).toList();
          return _Report(account.name, account.mobile, account.status, totalCredit, totalDebit, totalMoney, list);
        }

        return _getAccountReport(account, ++retryCount);
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return _getAccountReport(account, ++retryCount);}
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

    bool timeout = false;
    try {
      List<Account> accounts = await _getAccountList();
      _loadStep.value = 1;
      _accountsLoadProgress.value = _LoadingValue(0, accounts.length);
      _reports = [];

      var reports = _getReports(accounts);
      await for (final value in reports) {
        _accountsLoadProgress.value = value;
      }
    } on Exception {
      timeout = true;
    }

    setState(() {
      if (timeout) _isTimeout = true;
      _isLoading = false;
    });
  }

  void _downloadReport() {
    final data = ['Dreampay Report\n'];

    data.add('\nBuyer:\n');
    /// {'buyer1' : [transaction1, transaction2], }
    final Map<String, List<Transaction>> preCreditTransactions = {};
    for (var o in _reports!.where((element) => element.accountStatus is Buyer).toList()) {
      data.add('- (${o.accountMobile}) ${o.accountName}:\n'
          '  Debit = ${EnVar.MoneyFormat(o.accountDebit)};\n'
          '  Credit = ${EnVar.MoneyFormat(o.accountCredit)};\n'
          '  Saldo = ${EnVar.MoneyFormat(o.accountSum)};\n\n');

      // Pre-Credit Transactions
      for (var transaction in o.accountTransactions) {
        if (!transaction.is_debit) break;

        preCreditTransactions[o.accountName] ??= [];
        preCreditTransactions[o.accountName]!.add(transaction);
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
      data.add('- (${o.accountMobile}) ${o.accountName}:\n'
          '  Saldo = ${EnVar.MoneyFormat(o.accountSum*-1)};\n\n');

      // Duplicate Transactions
      for (var transaction in o.accountTransactions) {
        final duplicates = o.accountTransactions.where(
                (element) => element.depositor.mobile == transaction.depositor.mobile
                && element.transaction_amount == transaction.transaction_amount
        ).toList();

        if(duplicates.length > 1) {
          possibleDuplicateTransactions[o.accountName] ??= {};
          possibleDuplicateTransactions[o.accountName]![transaction.depositor.name] ??= [];

          if (!possibleDuplicateTransactions[o.accountName]![transaction.depositor.name]!.any(
                  (element) => element.any(
                          (element2) => element2.id == transaction.id))) {
            possibleDuplicateTransactions[o.accountName]![transaction.depositor.name]!.add(duplicates);
          }
        }
      }
    }

    data.add('\nPossible Duplicate Transactions:\n');
    for (var o in possibleDuplicateTransactions.entries) {
      data.add('- ${o.key}:\n');
      for (var o1 in o.value.entries) {
        data.add('  - ${o1.key}:\n');

        for (var i = 0; i < o1.value.length; ++i) {
          var o2 = o1.value[i];

          final ids = o2.map<String>((e) => e.id.toString()).toList();
          data.add('    ${i+1}. No. Note -> ${EnVar.getAllIdsAsString(ids)}: Amount = ${EnVar.MoneyFormat(o2[0].transaction_amount)};\n');
        }
      }
      data.add('\n');
    }

    data.add('\nPre-Credit Transactions:\n');
    for (var o in preCreditTransactions.entries) {
      data.add('- ${o.key}:\n');

      for (var i = 0; i < preCreditTransactions[o.key]!.length; ++i) {
        var o1 = preCreditTransactions[o.key]![i];

        data.add('  ${i+1}. No. Note -> ${o1.id}: Amount = ${EnVar.MoneyFormat(o1.transaction_amount)};\n');
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
