
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
      e['id'], (e['total'] as int).toDouble(),
      Account.parseClient(e['client']),
      (e['admin'] == null)
          ? null
          : ((e['admin']['id'] == null || e['admin']['id'] == '')
            ? null
            : Account.parseAdmin(e['admin'])),
      (e['cashier'] == null)
          ? null
          : ((e['cashier']['id'] == null || e['cashier']['id'] == '')
            ? null
            : Account.parseCashier(e['cashier'])),
      e['created_at']
  );
}