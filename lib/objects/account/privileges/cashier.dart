
import 'package:dreamwallet/objects/account/account_privilege.dart';

class Cashier extends AccountPrivilege {
  @override
  String toString() => 'Cashier';

  @override
  int toInt() => 4;

  @override
  String toChar() => 'C';
}