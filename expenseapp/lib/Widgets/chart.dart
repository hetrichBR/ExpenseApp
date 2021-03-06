import 'package:expenseapp/Models/transaction.dart';
import 'package:expenseapp/Widgets/chart_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chart extends StatelessWidget {

   final List<Transaction> recentTransactions;
   final Function _addNewTransaction;
   int dayOfWeek = 1;
   Chart(this.recentTransactions, this._addNewTransaction);
   
   List<Map<String, Object>> get groupedTransactions{
     return List.generate(7, (index){

      final today = DateTime.now();
      final weekDayNumber = today.weekday;
      final weekDay = today.subtract(Duration(days: weekDayNumber - index - 1));       
      var totalSum = 0.0;

       for(var i = 0; i < recentTransactions.length; i++){
         if(recentTransactions[i].date.day == weekDay.day 
            && recentTransactions[i].date.month == weekDay.month
            && recentTransactions[i].date.year == weekDay.year){
            totalSum += recentTransactions[i].amount;
         }
       }  

       return {'index': dayOfWeek++,'day': DateFormat.E().format(weekDay), 'amount': totalSum};
     });
   }

    double get totalSpending{
         return groupedTransactions.fold(0.0, (sum, item){
           return sum + item['amount'];
         });
    }

  @override
  Widget build(BuildContext context) { 
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: groupedTransactions.map((data){
          return Flexible(
            fit: FlexFit.tight, 
            child: ChartBar(
              _addNewTransaction,
              data['index'],
              data['day'], data['amount'], totalSpending == 0.0 ? 0.0 :(data['amount'] as double) / totalSpending)
              );
        }).toList()),
      ),
    );
  }
}