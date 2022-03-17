
import 'package:dreamwallet/objects/account/account.dart';

class Topup {
  int id;
  double total;
  Account client;
  Account? cashier;
  Account? admin;
  String created_at;

  bool selected = false;

  bool topuppedByCashier() => cashier != null;

  Topup(this.id, this.total, this.client, this.admin, this.cashier,
      this.created_at);

  static Topup parse(dynamic e) => Topup(
      e['id'], double.tryParse(e['total']) ?? 0,
      Account.parseClient(e['client']),
      (e['admin'] == null) ? null : Account.parseAdmin(e['admin']),
      (e['cashier'] == null) ? null : Account.parseCashier(e['cashier']),
      e['created_at']
  );
}