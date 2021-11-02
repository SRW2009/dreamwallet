
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends AccountPrivilege {
  @override
  String toString() {
    return 'Admin';
  }

  @override
  int toInt() => 3;

  @override
  String toChar() => 'A';
}
class Buyer extends AccountPrivilege {
  @override
  String toString() {
    return 'Buyer';
  }

  @override
  int toInt() => 1;

  @override
  String toChar() => 'B';
}
class Seller extends AccountPrivilege {
  @override
  String toString() {
    return 'Seller';
  }

  @override
  int toInt() => 2;

  @override
  String toChar() => 'S';
}

abstract class AccountPrivilege {
  int toInt();
  String toChar();

  static AccountPrivilege? parse(String a) {
    if (a == 'A' || a == 'Admin') return Admin();
    if (a == 'S' || a == 'Seller') return Seller();
    if (a == 'B' || a == 'Buyer') return Buyer();
    return null;
  }

  static AccountPrivilege? parseInt(int i) {
    if (i == 3) return Admin();
    if (i == 2) return Seller();
    if (i == 1) return Buyer();
    return null;
  }
}

class Account {
  static const String _PREFS_LOGIN_MOBILE = 'prefs_login_mobile';
  static const String _PREFS_LOGIN_NAME = 'prefs_login_name';
  static const String _PREFS_LOGIN_STATUS = 'prefs_login_status';
  static const String _PREFS_LOGIN_ISACTIVE = 'prefs_login_isactive';

  String mobile; // as primary key
  String name;
  AccountPrivilege status; // A: admin, B: Buyer, S: Seller
  bool isActive;

  Account(this.mobile, this.name, this.status, this.isActive);

  static Account parse(dynamic c) => Account(
      c['account_mobile'], c['account_name'], AccountPrivilege.parse(c['account_status'])!, c['is_active']);

  static Future<Account?> getAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString(_PREFS_LOGIN_MOBILE) == null) return null;
    return Account(
        prefs.getString(_PREFS_LOGIN_MOBILE)!,
        prefs.getString(_PREFS_LOGIN_NAME)!,
        AccountPrivilege.parse(prefs.getString(_PREFS_LOGIN_STATUS)!)!,
        prefs.getBool(_PREFS_LOGIN_ISACTIVE)!
    );
  }

  static Future<void> setAccount(Account account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_PREFS_LOGIN_MOBILE, account.mobile);
    await prefs.setString(_PREFS_LOGIN_NAME, account.name);
    await prefs.setString(_PREFS_LOGIN_STATUS, account.status.toString());
    await prefs.setBool(_PREFS_LOGIN_ISACTIVE, account.isActive);
  }
}