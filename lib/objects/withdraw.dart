
import 'package:dreamwallet/objects/account/account.dart';

class Withdraw {
  int id;
  double total;
  Account admin;
  Account merchant;
  String created_at;

  bool selected = false;

  Withdraw(this.id, this.total, this.admin, this.merchant, this.created_at);

  static Withdraw parse(dynamic e, [Account? account]) => Withdraw(
      e['id'], double.tryParse(e['total']) ?? 0,
      Account.parseAdmin(e['admin']),
      Account.parseMerchant(e['merchant']),
      e['created_at']
  );
}