import 'package:flutter/foundation.dart';

class Transaction{
  @required  int id;
  @required  String title;
  @required  double amount;
  @required  DateTime date;
  @required  bool isEssential;

  Transaction({this.id, this.title, this.date, this.amount, this.isEssential});

  Transaction.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      amount = json['amount'],
      date = DateTime.parse(json['date']),
      isEssential = json['isEssential'];

  Map<String, dynamic> toJson() => {
      'id' : id,
      'title' : title,
      'amount' : amount,
      'date' : date.toString(),
      'isEssential' : isEssential
  };
}