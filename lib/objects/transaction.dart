
import 'package:dreamwallet/objects/account.dart';

class Transaction {
  int id;
  bool is_debit;
  String transactionName;
  int transaction_amount;
  String transaction_date;
  String transaction_depositor;
  String transaction_receiver;
  Account depositor;
  Account receiver;

  bool selected = false;

  Transaction(
      this.id,
      this.is_debit,
      this.transactionName,
      this.transaction_amount,
      this.transaction_date,
      this.transaction_depositor,
      this.transaction_receiver,
      this.depositor,
      this.receiver);

  static Transaction parse(dynamic e) => Transaction(
      e['id'], e['is_debit'], e['TransactionName'],
      e['transaction_amount'], e['transaction_date'],
      e['transaction_depositor'], e['transaction_receiver'],
      Account.parse(e['DDepositor']), Account.parse(e['DReceiver'])
  );
}