import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {

  final Function addTransactionRef;
  NewTransaction(this.addTransactionRef);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool isEssential = true;
  DateTime selectedDate = DateTime.now();

  void _presentDatePicker()
  {
    showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(DateTime.now().year), lastDate: DateTime.now(), )
       .then((date) {
         if(date == null){
           return;
         }
         setState(() {
            selectedDate = date;
         });
       });
  }

  void submitData()
  {
    final enteredTitle = titleController.text;
    var enteredAmount = double.parse(amountController.text);

    if(enteredTitle.isEmpty && enteredAmount <= 0 && selectedDate == null)
    {
      return;
    }

    widget.addTransactionRef(enteredTitle, enteredAmount, selectedDate, isEssential);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
      final mediaQuery = MediaQuery.of(context);
      final isLandscape = mediaQuery.orientation == Orientation.landscape;
      return SingleChildScrollView(
              child: Card(elevation: 5,
                 child: Container(
                   padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: mediaQuery.viewInsets.bottom + 10),
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Container(alignment: Alignment.topCenter, child: Text('New Expense', style: Theme.of(context).textTheme.title)),
                      Divider(thickness: 1,),
                      //if(Platform.isIOS) Container(margin: EdgeInsets.only(bottom: 10), child: CupertinoTextField(placeholder: 'Title', controller: titleController,)),
                      //if(Platform.isIOS) Container(margin: EdgeInsets.only(bottom: 10), child: CupertinoTextField(placeholder: 'Amount', keyboardType: TextInputType.number, controller: amountController,)),
                      Container(
                        height: !isLandscape ? mediaQuery.size.height * .1 : mediaQuery.size.height * .15,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(width: mediaQuery.size.width / 2, child: TextField(decoration: InputDecoration(labelText: 'Title'), controller: titleController)),
                        ],
                      )), 
                      Container(width: mediaQuery.size.width, 
                      height: !isLandscape ? mediaQuery.size.height * .1 : mediaQuery.size.height * .15, 
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                             Container(width: mediaQuery.size.width / 2, child: TextField(decoration: InputDecoration(labelText: 'Amount'), controller: amountController, keyboardType: TextInputType.number)),
                            Container(padding: EdgeInsets.all(8), width: 100, height: mediaQuery.size.height ,child: Image.asset('assets/images/money-coin-label.png'))
                         ],
                       ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: mediaQuery.size.width / 2,
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                              FlatButton(splashColor: Theme.of(context).accentColor ,child: Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),), padding: EdgeInsets.only(right: 0), textColor: Theme.of(context).primaryColor, onPressed: _presentDatePicker),
                              Expanded(child: Text(selectedDate == null ? 'Select Date' : '${DateFormat.yMd().format(selectedDate)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 14),)),
                            ],),
                          ),
                        ],
                      ),
                       Row(
                        children: <Widget>[
                          Container(
                            width: mediaQuery.size.width / 2,
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                              Expanded(child: Text('Essential Expense:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor),)),
                              Switch.adaptive(value: isEssential, onChanged: (val){setState(() {isEssential = val;});})
                            ],),
                          ),
                        ],
                      ),
                      selectedDate == null || amountController.text == '' || titleController.text == '' ? Container(): Container(width: mediaQuery.size.width, alignment: Alignment.centerRight,child: Container(width: mediaQuery.size.width, child: RaisedButton(child: Text('Add Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),), color:Theme.of(context).primaryColor, textColor: Theme.of(context).textTheme.button.color, onPressed: submitData))),
                    ]),
                    )
                  ),
      );
  }
}