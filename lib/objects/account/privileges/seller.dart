
import 'package:dreamwallet/objects/account/account_privilege.dart';

class Seller extends AccountPrivilege {
  @override
  String toString() => 'Seller';

  @override
  int toInt() => 2;

  @override
  String toChar() => 'S';
}