import 'package:expenseapp/Models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {

  final List<Transaction> transactions;
  final Function deleteTransactionRef;
  final int selectedMonth;

  TransactionList(this.transactions, this.deleteTransactionRef, this.selectedMonth);
  
    @override
    Widget build(BuildContext context) {

      final mediaQuery = MediaQuery.of(context);
      final formatCurrency = new NumberFormat.simpleCurrency();


      return transactions.isEmpty
        ? LayoutBuilder(builder: (context, constraints)
        {
          return Column(
            children: <Widget>[
            selectedMonth == DateTime.now().month ? SizedBox(height: 0,) : SizedBox(height: constraints.maxHeight * .2,),
            Text('No transactions added yet!', style: Theme.of(context).textTheme.title),
            SizedBox(height: 30,),
            Container(height: selectedMonth == DateTime.now().month ? constraints.maxHeight * .6 : constraints.maxHeight * .4, child: Image.asset('assets/images/panda-asleep.png', fit: BoxFit.cover,))
            ],
          );
        })
        : ListView.builder(
                itemBuilder: (context, index) 
                {
                  return Dismissible(
                        key: ValueKey(transactions[index].id),
                        onDismissed: (_)=>deleteTransactionRef(transactions[index].id),
                        background: Container(margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5), alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), color: Theme.of(context).errorColor, child: Icon(Icons.delete, color: Colors.white),),
                        direction: DismissDirection.endToStart,
                        child: Card(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                            
                            elevation: 5,
                            child: Container(
                            decoration: BoxDecoration(/*borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),*/ border: Border(left: BorderSide(color: Theme.of(context).accentColor, width: 7))),
                            child: ListTile(                  
                              leading: CircleAvatar(radius: 30, child: Padding(padding: EdgeInsets.all(6), child: FittedBox(child: Text('${formatCurrency.format(transactions[index].amount)}')))),
                              title: transactions[index].isEssential ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(transactions[index].title, style: Theme.of(context).textTheme.title,),
                                  SizedBox(width: mediaQuery.size.width * .01,),
                                  CircleAvatar(backgroundColor: Theme.of(context).accentColor, radius: 8, child: Padding(padding: EdgeInsets.all(3), child: FittedBox(child: Text('es'))))
                                ],
                              ) 
                              : Text(transactions[index].title, style: Theme.of(context).textTheme.title,),
                              subtitle: Text(DateFormat.yMMMd().format(transactions[index].date),),
                              trailing: mediaQuery.size.width > 800
                              ? FlatButton.icon(textColor: Theme.of(context).errorColor, icon: Icon(Icons.delete), label: Text('Delete'), onPressed: () => deleteTransactionRef(transactions[index].id))
                              : IconButton(icon: Icon(Icons.delete, color: Theme.of(context).errorColor,), onPressed: () => deleteTransactionRef(transactions[index].id),
                          ),
                    ),
                            )),
                  );
                },
                itemCount: transactions.length
        );
    }
}

