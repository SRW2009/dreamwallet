
import 'package:dreamwallet/objects/account/account_privilege.dart';

class Buyer extends AccountPrivilege {
  @override
  String toString() => 'Buyer';

  @override
  int toInt() => 1;

  @override
  String toChar() => 'B';
}