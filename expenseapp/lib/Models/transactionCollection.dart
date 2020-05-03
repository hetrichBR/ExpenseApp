import 'package:expenseapp/Models/transaction.dart';

class TransactionCollection{

  final List<Transaction> transactions;
  
  TransactionCollection(this.transactions);

  TransactionCollection.fromJson(Map<String, dynamic> json)
    : transactions = json['transactions'] != null ? List<Transaction>.from(json['transactions']) : null;
  
  Map<String, dynamic> toJson() =>
  {
    'transactions' : transactions
  };

}