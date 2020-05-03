import 'package:expenseapp/Models/transaction.dart';
import 'package:flutter/material.dart';

class ExpensesOverview extends StatelessWidget {

  final List<Transaction> transactions;
  ExpensesOverview(this.transactions);
  
  @override
  Widget build(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height *.4,
      child: Card(elevation: 5,
                 child: Container(
                   padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: mediaQuery.viewInsets.bottom + 10),
                   child: Column(children: <Widget>[                      
                     Container(alignment: Alignment.topCenter, child: Text('Summary', style: Theme.of(context).textTheme.title)),
                     Divider()
                    ],),
                 )
    ));
  }
}