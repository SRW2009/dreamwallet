
import 'package:dreamwallet/objects/account/account.dart';

class Transaction {
  int id;
  double total;
  Account client;
  Account merchant;
  String created_at;

  bool selected = false;

  Transaction(this.id, this.total, this.client, this.merchant, this.created_at);

  static Transaction parse(dynamic e) => Transaction(
      e['id'], double.tryParse(e['total']) ?? 0,
      Account.parseClient(e['client']),
      Account.parseMerchant(e['merchant']),
      e['created_at']
  );
}