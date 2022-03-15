
import 'package:dreamwallet/objects/account/account.dart';

class Withdraw {
  int id;
  String seller_id;
  int amount;
  Account seller;

  bool selected = false;

  Withdraw(this.id, this.seller_id, this.amount, this.seller);

  static Withdraw parse(dynamic e, [Account? account]) => Withdraw(
      e['ID'], e['seller_id'], e['amount'],
      account ?? Account.parse(e['S'])
  );
}