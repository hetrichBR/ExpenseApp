import 'package:expenseapp/Models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatefulWidget {

  final List<Transaction> transactions;
  final Function deleteTransactionRef;
  final int selectedMonth;
  final Animation<Offset> _offsetAnimation;
  final GlobalKey<AnimatedListState> _animatedListKey; 
  bool gridView;

  TransactionList(this.transactions, this.deleteTransactionRef, this.selectedMonth, this._offsetAnimation, this._animatedListKey, this.gridView);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var sort = true;
  var sortEssential = true;
  var sortAmount = true;
  var sortDate = true;
  int sortColumnIndex = 0;

  onSortColum(int columnIndex, bool ascending) {

  if (columnIndex == 0) {
    if (ascending) {
      widget.transactions.sort((a, b) => a.isEssential.toString().compareTo(b.isEssential.toString()));
    } else {
      widget.transactions.sort((a, b) => b.isEssential.toString().compareTo(a.isEssential.toString()));
    }
  }
  if (columnIndex == 1) {
    if (ascending) {
      widget.transactions.sort((a, b) => a.amount.compareTo(b.amount));
    } else {
      widget.transactions.sort((a, b) => b.amount.compareTo(a.amount));
    }
  }
  if (columnIndex == 2) {
    if (ascending) {
      widget.transactions.sort((a, b) => a.date.compareTo(b.date));
    } else {
      widget.transactions.sort((a, b) => b.date.compareTo(a.date));
    }
  }
}

    @override
    Widget build(BuildContext context) {
      print(widget.gridView);
      final mediaQuery = MediaQuery.of(context);
      final formatCurrency = new NumberFormat.simpleCurrency();
      var listWidget = AnimatedList(
                key: widget._animatedListKey,
                initialItemCount: widget.transactions.length,
                itemBuilder: (context, index, animation) 
                {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                            key: ValueKey(widget.transactions[index].id),
                            onDismissed: (_)=>widget.deleteTransactionRef(widget.transactions[index].id),
                            background: Container(margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5), alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), color: Theme.of(context).errorColor, child: Icon(Icons.delete, color: Colors.white),),
                            direction: DismissDirection.endToStart,
                            child: Card(
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                                
                                elevation: 5,
                                child: Container(
                                decoration: BoxDecoration(/*borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),*/ border: Border(left: BorderSide(color: Theme.of(context).accentColor, width: 7))),
                                child: ListTile(                  
                                  leading: CircleAvatar(radius: 30, child: Padding(padding: EdgeInsets.all(6), child: FittedBox(child: Text('${formatCurrency.format(widget.transactions[index].amount)}')))),
                                  title: widget.transactions[index].isEssential ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(widget.transactions[index].title, style: Theme.of(context).textTheme.title,),
                                      SizedBox(width: mediaQuery.size.width * .01,),
                                      CircleAvatar(backgroundColor: Theme.of(context).accentColor, radius: 8, child: Padding(padding: EdgeInsets.all(3), child: FittedBox(child: Text('es'))))
                                    ],
                                  ) 
                                  : Text(widget.transactions[index].title, style: Theme.of(context).textTheme.title,),
                                  subtitle: Text(DateFormat.yMMMd().format(widget.transactions[index].date),),
                                  trailing: mediaQuery.size.width > 800
                                  ? FlatButton.icon(textColor: Theme.of(context).errorColor, icon: Icon(Icons.delete), label: Text('Delete'), onPressed: () => widget.deleteTransactionRef(widget.transactions[index].id))
                                  : IconButton(icon: Icon(Icons.delete, color: Theme.of(context).errorColor,), onPressed: () => widget.deleteTransactionRef(widget.transactions[index].id),
                              ),
                        ),
                                )),
                      
                    ),
                  );
                },
        );
      var gridWidget = SingleChildScrollView(
          child: Card(
            child: DataTable(
                  sortAscending: sort, 
                  sortColumnIndex: sortColumnIndex,
                  columns: <DataColumn>[
                    DataColumn(
                       onSort: (columnIndex, ascending) { 
                          setState(() {
                              if(columnIndex == sortColumnIndex)
                              {
                                  sort = !sort;
                              }
                              sortColumnIndex = columnIndex;

                          });
                          onSortColum(columnIndex, ascending);
                        },
                        label: Text(
                          'Expense',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ),
                    DataColumn(
                        onSort: (columnIndex, ascending) { 
                          setState(() {
                              if(columnIndex == sortColumnIndex)
                              {
                                sort = !sort;
                              }
                              sortColumnIndex = columnIndex;
                          });
                          onSortColum(columnIndex, ascending);
                        },
                        label: Text(
                          'Amount',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ),
                    DataColumn( onSort: (columnIndex, ascending) { 
                          setState(() {
                              if(columnIndex == sortColumnIndex)
                              {
                                sort = !sort;
                              }
                              sortColumnIndex = columnIndex;

                          });
                          onSortColum(columnIndex, ascending);
                        },
                        label: Text(
                          'Date',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ),
                  ],
                  rows: widget.transactions.map((element) => DataRow(
                          cells: <DataCell>[
                            DataCell(Row(
                              children: <Widget>[
                                element.isEssential ? CircleAvatar(backgroundColor: Theme.of(context).accentColor, radius: 4, child: Padding(padding: EdgeInsets.all(0), child: FittedBox(child: Text('')))): SizedBox(),
                                SizedBox(width: 2),
                                Text(element.title),
                              ],
                            )), //Extracting from Map element the value
                            DataCell(Text('${formatCurrency.format(element.amount)}')),
                            DataCell(Text(DateFormat.MMMd().format(element.date))),
                            //DataCell(IconButton(icon: Icon(Icons.delete), color:Theme.of(context).errorColor, onPressed: () => widget.deleteTransactionRef(element.id)))
                          ],
                        )).toList(),
              ),
          ),
        );

      return widget.transactions.isEmpty
        ? LayoutBuilder(builder: (context, constraints)
        {
          return Column(
            children: <Widget>[
            widget.selectedMonth == DateTime.now().month ? SizedBox(height: 0,) : SizedBox(height: constraints.maxHeight * .2,),
            Text('No transactions added yet!', style: Theme.of(context).textTheme.title),
            SizedBox(height: 30,),
            Container(height: widget.selectedMonth == DateTime.now().month ? constraints.maxHeight * .6 : constraints.maxHeight * .4, child: Image.asset('assets/images/panda-asleep.png', fit: BoxFit.cover,))
            ],
          );
        })
        : widget.gridView ? gridWidget : listWidget ;
    }
}

