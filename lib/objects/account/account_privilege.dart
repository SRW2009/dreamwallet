
import 'privileges/root.dart';

abstract class AccountPrivilege with _APMixin {
  int toInt();
  String toChar();
  static AccountPrivilege? parse(String a) => _APMixin.$parse(a);
  static AccountPrivilege? parseInt(int i) => _APMixin.$parseInt(i);

  @override
  bool operator ==(Object other) => (other is AccountPrivilege)
      && other.toInt() == toInt();

  @override
  int get hashCode =>
      toString().hashCode ^ toInt().hashCode ^ toChar().hashCode;
}

mixin _APMixin {
  static AccountPrivilege? $parse(String a) {
    if (a == 'A' || a == 'Admin') return Admin();
    if (a == 'S' || a == 'Seller') return Seller();
    if (a == 'B' || a == 'Buyer') return Buyer();
    if (a == 'C' || a == 'Cashier') return Cashier();
    return null;
  }

  static AccountPrivilege? $parseInt(int i) {
    if (i == 3) return Admin();
    if (i == 2) return Seller();
    if (i == 1) return Buyer();
    if (i == 4) return Cashier();
    return null;
  }
}