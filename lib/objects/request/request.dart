
import 'dart:convert';

import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/objects/topup.dart';
import 'package:dreamwallet/objects/transaction.dart';
import 'package:dreamwallet/objects/withdraw.dart';
import 'package:http/http.dart' as http;

import '../account/account.dart';
import '../account/privileges/root.dart';
import 'urls.dart';

abstract class _Req {
  Future<_LoginResponse> login(String phone, AccountPrivilege privilege);

  Future<int> clientRegister(String phone, String name);
  Future<int> clientCreateTransaction(String phone, int amount);
  Future<List<Transaction>> clientGetTransactions();

  Future<List<Transaction>> merchantGetTransactions();
  Future<List<Withdraw>> merchantGetWithdrawals();

  Future<int> cashierTopup(double total, int clientId);
  Future<List<Topup>> cashierGetTopups();
  Future<List<Account>> cashierGetClients();

  Future<List<Account>> adminGetAccounts();
  Future<int> adminVerifyClient(int clientId);
  Future<int> adminCreateCashier(String phone, String name);
  Future<int> adminCreateMerchant(String phone, String name);
  Future<List<Topup>> adminGetTopups(int? cashierId);
  Future<List<Withdraw>> adminGetWithdrawals();
  Future<List<Transaction>> adminGetTransactions();
  Future<List<Account>> adminGetMerchants();
  Future<int> adminVerifyTopups(List<int> ids);
  Future<int> adminTopup(double total, int clientId);
  Future<int> adminCreateWithdrawal(int merchantId, double total);
}

class Request with Urls implements _Req {
  static final Request _instance = Request._internal();
  Request._internal();
  factory Request() => _instance;

  @override
  Future<_LoginResponse> login(String phone, AccountPrivilege privilege) async {
    final formPhone = '62'+phone;
    String? url;
    if (privilege is Buyer) url = clientLoginUrl;
    if (privilege is Seller) url = merchantLoginUrl;
    if (privilege is Cashier) url = cashierLoginUrl;
    if (privilege is Admin) url = adminLoginUrl;
    print(url);
    final response = await http.post(
      Uri.parse(url!),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'phone': formPhone,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String? priv;
      if (privilege is Buyer) priv = 'client';
      if (privilege is Seller) priv = 'merchant';
      if (privilege is Cashier) priv = 'cashier';
      if (privilege is Admin) priv = 'admin';
      final account = Account(0, phone, data[priv!], privilege,
          token: data['token']);
      bool? isActive = data['client']?['is_active'];

      if (isActive != null && !isActive) {
        return _LoginResponse(response.statusCode, null);
      }

      await Account.setAccount(account);
      return _LoginResponse(response.statusCode, account);
    }
    return _LoginResponse(response.statusCode, null);
  }

  @override
  Future<int> clientRegister(String phone, String name) async {
    final formPhone = '62'+phone;
    final response = await http.post(
      Uri.parse(clientRegisterUrl),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'account_mobile': formPhone,
        'account_name' : name,
      }),
    );
    return response.statusCode;
  }

  @override
  Future<int> clientCreateTransaction(String phone, int amount) async {
    DateTime date = DateTime.now();
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(clientCreateTransactionUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        "is_debit": false,
        "transaction_amount": amount,
        "transaction_date": date.toIso8601String().split('T')[0],
        "merchant_id": phone
      }),
    );
    return response.statusCode;
  }

  @override
  Future<List<Transaction>> clientGetTransactions() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(clientGetTransactionsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Transaction>((e) => Transaction.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<int> adminCreateCashier(String phone, String name) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminCreateCashierUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'name': name,
        'phone': phone,
      }),
    );
    return response.statusCode;
  }

  @override
  Future<int> adminCreateMerchant(String phone, String name) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminCreateMerchantUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'name': name,
        'phone': phone,
      }),
    );
    return response.statusCode;
  }

  @override
  Future<List<Account>> adminGetAccounts() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(adminGetAccountsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Account>((e) => Account.parseClient(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Account>> adminGetMerchants() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(adminGetMerchantsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Account>((e) => Account.parseMerchant(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Topup>> adminGetTopups(int? cashierId) async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
    Uri.parse(cashierId == null
        ? adminGetTopupsUrl
        : '$adminGetTopupsUrl?cashier_id=$cashierId'),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      print('topup');
      return list.map<Topup>((e) => Topup.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Withdraw>> adminGetWithdrawals() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(adminGetWithdrawalsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      print('withdraw');
      return list.map<Withdraw>((e) => Withdraw.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<int> adminTopup(double total, int clientId) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminTopupUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'client_id': clientId,
        'total': total.toInt(),
      }),
    );

    return response.statusCode;
  }

  @override
  Future<int> adminVerifyTopups(List<int> ids) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminVerifyTopupsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'topup_id': ids
      }),
    );

    return response.statusCode;
  }

  @override
  Future<int> adminVerifyClient(int clientId) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminVerifyClientUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'client_id': clientId
      }),
    );

    return response.statusCode;
  }

  @override
  Future<List<Account>> cashierGetClients() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(cashierGetClientsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Account>((e) => Account.parseClient(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Topup>> cashierGetTopups() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(cashierGetTopupsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Topup>((e) => Topup.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<int> cashierTopup(double total, int clientId) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(cashierTopupUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'total': total.toInt(),
        'client_id': clientId
      }),
    );

    return response.statusCode;
  }

  @override
  Future<List<Transaction>> merchantGetTransactions() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(merchantGetTransactionsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Transaction>((e) => Transaction.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Withdraw>> merchantGetWithdrawals() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(merchantGetWithdrawalsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map<Withdraw>((e) => Withdraw.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<List<Transaction>> adminGetTransactions() async {
    Account account = (await Account.getAccount())!;

    final response = await http.get(
      Uri.parse(adminGetTransactionsUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
    );

    print([response.statusCode, response.body]);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      print('transactions');
      return list.map<Transaction>((e) => Transaction.parse(e)).toList();
    }
    throw Exception();
  }

  @override
  Future<int> adminCreateWithdrawal(int merchantId, double total) async {
    Account? account = await Account.getAccount();
    if (account == null) return 0;

    final response = await http.post(
      Uri.parse(adminCreateWithdrawalUrl),
      headers: EnVar.HTTP_HEADERS(token: account.token),
      body: jsonEncode({
        'merchant_id': merchantId,
        'total': total.toInt(),
      }),
    );
    return response.statusCode;
  }
}

class _LoginResponse {
  final int statusCode;
  final Account? account;

  _LoginResponse(this.statusCode, this.account);
}