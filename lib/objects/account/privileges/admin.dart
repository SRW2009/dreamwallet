
import 'package:dreamwallet/objects/account/account_privilege.dart';

class Admin extends AccountPrivilege {
  @override
  String toString() => 'Admin';

  @override
  int toInt() => 3;

  @override
  String toChar() => 'A';
}