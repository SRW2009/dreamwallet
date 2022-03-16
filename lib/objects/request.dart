
import 'dart:convert';

import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:http/http.dart' as http;

import 'account/account.dart';
import 'account/privileges/root.dart';

abstract class _R {
  Future<_LoginResponse> login(String phone, AccountPrivilege privilege);
  Future<int> register(String phone, String name);
}

class Request implements _R {
  static const Request _instance = Request._internal();
  const Request._internal();
  factory Request() => _instance;

  @override
  Future<_LoginResponse> login(String phone, AccountPrivilege privilege) async {
    final formPhone = '62'+phone;
    String? url;
    if (privilege is Buyer) url = '/v1/client/login/';
    if (privilege is Seller) url = '/v1/merchant/login/';
    if (privilege is Cashier) url = '/v1/cashier/login/';
    if (privilege is Admin) url = '/v1/admin/login/';
    final response = await http.post(
      Uri.parse('${EnVar.API_URL_HOME}/$url'),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'phone': formPhone,
      }),
    );
    if (response.statusCode == 202) {
      final data = jsonDecode(response.body)['data'];
      bool isActive = data['is_active'];

      if (isActive) {
        String name = data['account_name'];
        String phone = data['account_mobile'];
        String status = data['account_status'];
        Account account = Account(
            phone, name, AccountPrivilege.parse(status)!, isActive
        );
        await Account.setAccount(account);

        return _LoginResponse(response.statusCode, account);
      }
    }
    return _LoginResponse(response.statusCode, null);
  }

  @override
  Future<int> register(String phone, String name) async {
    final formPhone = '62'+phone;
    final response = await http.post(
      Uri.parse('${EnVar.API_URL_HOME}/register'),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'account_mobile': formPhone,
        'account_name' : name,
        'account_status': 'B',
      }),
    );
    if (response.statusCode == 201) {
      Account account = Account(formPhone, name, Buyer(), false);
      await Account.setAccount(account);
    }
    return response.statusCode;
  }
}

class _LoginResponse {
  final int statusCode;
  final Account? account;

  _LoginResponse(this.statusCode, this.account);
}