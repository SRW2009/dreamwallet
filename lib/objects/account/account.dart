
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privileges/root.dart';

class Account {
  static const String _PREFS_LOGIN_ID= 'prefs_login_id';
  static const String _PREFS_LOGIN_MOBILE = 'prefs_login_mobile';
  static const String _PREFS_LOGIN_NAME = 'prefs_login_name';
  static const String _PREFS_LOGIN_STATUS = 'prefs_login_status';
  static const String _PREFS_LOGIN_TOKEN = 'prefs_login_token';

  int id; // as primary key
  String mobile;
  String name;
  AccountPrivilege status; // A: admin, B: Buyer, S: Seller, C: Cashier
  String? token;
  bool? is_active;

  Account(this.id, this.mobile, this.name, this.status, {this.token});

  factory Account.parseClientInAdminAccount(dynamic c) => Account(
    c['id'], c['phone'], c['name'], Buyer(),
  )..is_active=c['is_active'];

  factory Account.parseClient(dynamic c) => Account(
    c['id'], '', c['name'], Buyer(),
  );

  factory Account.parseMerchant(dynamic c) => Account(
    c['id'], '', c['name'], Seller(),
  );

  factory Account.parseCashier(dynamic c) => Account(
    c['id'], '', c['name'], Cashier(),
  );

  factory Account.parseAdmin(dynamic c) => Account(
    c['id'], '', c['name'], Admin(),
  );
  factory Account.parseOld(dynamic c) => Account(0, c['account_mobile'], c['account_name'], Buyer());

  @override
  bool operator ==(Object other) => (other is Account)
      && other.id == id
      && other.status == status
      && other.name == name
      && other.mobile == mobile;

  @override
  int get hashCode =>
      id.hashCode ^ status.hashCode ^ name.hashCode ^ mobile.hashCode;

  static Future<Account?> getAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt(_PREFS_LOGIN_ID) == null) return null;
    return Account(
      prefs.getInt(_PREFS_LOGIN_ID)!,
      prefs.getString(_PREFS_LOGIN_MOBILE)!,
      prefs.getString(_PREFS_LOGIN_NAME)!,
      AccountPrivilege.parse(prefs.getString(_PREFS_LOGIN_STATUS)!),
      token: prefs.getString(_PREFS_LOGIN_TOKEN)
    );
  }

  static Future<void> setAccount(Account account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_PREFS_LOGIN_ID, account.id);
    await prefs.setString(_PREFS_LOGIN_MOBILE, account.mobile);
    await prefs.setString(_PREFS_LOGIN_NAME, account.name);
    await prefs.setString(_PREFS_LOGIN_STATUS, account.status.toChar());
    if (account.token != null) await prefs.setString(_PREFS_LOGIN_TOKEN, account.token!);
  }

  static Future<bool> unsetAccount() async {
    Temp.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}