
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account {
  static const String _PREFS_LOGIN_ID= 'prefs_login_mobile';
  static const String _PREFS_LOGIN_MOBILE = 'prefs_login_mobile';
  static const String _PREFS_LOGIN_NAME = 'prefs_login_name';
  static const String _PREFS_LOGIN_STATUS = 'prefs_login_status';
  static const String _PREFS_LOGIN_ISACTIVE = 'prefs_login_isactive';

  int id; // as primary key
  String mobile;
  String name;
  AccountPrivilege status; // A: admin, B: Buyer, S: Seller, C: Cashier
  bool isActive;

  Account(this.id, this.mobile, this.name, this.status, this.isActive);

  static Account parse(dynamic c) => Account(
      c['id'], c['account_mobile'], c['account_name'],
      AccountPrivilege.parse(c['account_status'])!, c['is_active']);

  static Future<Account?> getAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt(_PREFS_LOGIN_ID) == null) return null;
    return Account(
      prefs.getInt(_PREFS_LOGIN_ID)!,
      prefs.getString(_PREFS_LOGIN_MOBILE)!,
      prefs.getString(_PREFS_LOGIN_NAME)!,
      AccountPrivilege.parse(prefs.getString(_PREFS_LOGIN_STATUS)!)!,
      prefs.getBool(_PREFS_LOGIN_ISACTIVE)!,
    );
  }

  static Future<void> setAccount(Account account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_PREFS_LOGIN_ID, account.id);
    await prefs.setString(_PREFS_LOGIN_MOBILE, account.mobile);
    await prefs.setString(_PREFS_LOGIN_NAME, account.name);
    await prefs.setString(_PREFS_LOGIN_STATUS, account.status.toString());
    await prefs.setBool(_PREFS_LOGIN_ISACTIVE, account.isActive);
  }
}