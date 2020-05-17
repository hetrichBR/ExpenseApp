import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:expenseapp/Widgets/chart.dart';
import 'package:expenseapp/Widgets/new_transaction.dart';
import 'package:expenseapp/Widgets/transactions_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'Models/transaction.dart';
import 'Widgets/expenses_overview.dart';
import 'Widgets/month_list.dart';
import 'storage.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amberAccent,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(title: TextStyle(fontFamily: 'OpenSans', fontSize: 18, fontWeight: FontWeight.bold), button: TextStyle(color: Colors.white)),
        appBarTheme: AppBarTheme(textTheme: ThemeData.light().textTheme.copyWith(title: TextStyle(fontFamily: 'OpenSans', fontSize: 20, fontWeight: FontWeight.bold)))
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', storage: Storage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  final String title;
  final Storage storage;
  MyHomePage({Key key, this.title, @required this.storage}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  ConfettiController _controllerBottomCenter;
  ConfettiController _controllerTopCenter;
  AnimationController animationControllerChart;
  AnimationController animationControllerList;
  Animation<Offset> _offsetAnimationList;
  Animation<Offset> _offsetAnimationChart;
  GlobalKey<AnimatedListState> _animatedListKey;

  

  @override
  void initState() {
     _controllerBottomCenter = ConfettiController(duration: const Duration(seconds: 4));
     _controllerTopCenter = ConfettiController(duration: const Duration(seconds: 4));
     animationControllerChart = AnimationController(vsync: this, duration: const Duration(seconds: 3));
     animationControllerList = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animatedListKey = GlobalKey<AnimatedListState>();


     _offsetAnimationList = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: animationControllerList,
      curve: Curves.fastOutSlowIn,
    ));

    _offsetAnimationChart = Tween<Offset>(
      begin: Offset(0.0, -1.1),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: animationControllerChart,
      curve: Curves.fastOutSlowIn,
    ));

    super.initState();
   widget.storage.localPath.then((path) =>{
      _appDir = path
    });
    widget.storage.readData().then((data) => {
      readData(data)
    });

    animationControllerChart.forward();
    animationControllerList.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerBottomCenter.dispose();
    _controllerTopCenter.dispose();
    animationControllerChart.dispose();
    animationControllerList.dispose();

  }

  String _appDir;
  final List<Transaction> transactions = [];
  List<Transaction> displayedTransactions = [];

  bool showChart = true;
  int transactionDisplayMonth = DateTime.now().month;
  final formatCurrency = new NumberFormat.simpleCurrency();

  static List<Month> _months = Month.getMonths();
  List<DropdownMenuItem<Month>> _dropDownItems;
  Month selectedMonth = _months.where((m)=>m.value == DateTime.now().month).first;
  List<DropdownMenuItem<Month>> buildList(List months)
  {
    List<DropdownMenuItem<Month>> items = List();
    for(Month month in months)
    {
      items.add(
        DropdownMenuItem(
            value: month,
            child: Text(month.name),
        )
      );
   }
   return items;
  }

  onChangeMonths(Month selection)
  {
    setState(() {
        transactionDisplayMonth = selection.value;
        selectedMonth = selection;
        //remove items from animated list
        for(int i = 0; i < displayedTransactions.length - 1; i++)
        {
           if(displayedTransactions.length > 0)
           {  
              if(_animatedListKey.currentState != null)
              _animatedListKey.currentState.removeItem(i, (context, animation){
              return SizedBox();
              });
           }
        }
        print(_animatedListKey.currentState);
        displayedTransactions = transactions.where((t) => t.date.month == transactionDisplayMonth).toList();
        displayedTransactions.sort((a,b) => a.date.compareTo(b.date));

        //add items from animated list
        for(int i = 0; i < displayedTransactions.length -1; i++)
        {
          if(displayedTransactions.length > 0)
           {
              if(_animatedListKey.currentState != null)
                _animatedListKey.currentState.insertItem(0);
           }
        }
        print(_animatedListKey);
        print(_animatedListKey.currentState);

        if(displayedTransactions.length != 0)
        {
            if(selectedMonth.value == DateTime.now().month)
            {
              animationControllerChart.forward(from: 0);
              animationControllerList.forward(from: 0);
            }

            else
            {
              animationControllerChart.reverse();
              animationControllerList.forward(from: 0); 
            }
        }
        else{
          if(selectedMonth.value == DateTime.now().month)
            {
              animationControllerChart.forward(from: 0);
            }
        }
       

    });
  }

  List<Transaction> get _recentTransactions {
    return transactions.where((t){
      return t.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

    double get totalMonthExpenses{
         return displayedTransactions.fold(0.0, (sum, item){
           return sum + item.amount;
         });
    }


  void _addNewTransaction(String title, double amount, DateTime date, bool isEssential)
  {
    final newTransaction = Transaction(title: title, amount: amount, date: date, id: UniqueKey().hashCode, isEssential: isEssential);
    setState(() {
      transactions.add(newTransaction);
      if(_animatedListKey.currentState != null)
        _animatedListKey.currentState.insertItem(0);
      displayedTransactions = transactions.where((t) => t.date.month == selectedMonth.value).toList();
      displayedTransactions.sort((a,b) => a.date.compareTo(b.date));
      saveData(transactions);
      if(displayedTransactions.length == 1)
      {
         _controllerBottomCenter.play();
        // _controllerTopCenter.play();
      }
      //animationController.forward();
    });
  }

  void saveData(List<Transaction> transactions)
  {
      var json = "[";
      for(var i = 0; i < transactions.length; i++)
      {
        var jsonObj = jsonEncode(transactions[i].toJson());
        json += jsonObj;
        
        if(i < transactions.length - 1)
          json += ",";

      }
      json += "]";
      widget.storage.writeData(json);

      widget.storage.readData().then((data) => {
    });
  }

    readData(String data){
    var fileList = [];
    if(data != null || data != "")
    {
       fileList = (jsonDecode(data) as List).map((f) => Transaction.fromJson(f)).toList();
    }
    print("FILE LIST");
    print(fileList[0].title);
    setState(() {
      for(var i = 0; i < fileList.length; i++){
      transactions.add(fileList[i]);
    }
    displayedTransactions = transactions.where((t) => t.date.month == selectedMonth.value).toList();
    displayedTransactions.sort((a,b) => a.date.compareTo(b.date));
    print(transactions);
    });   
}

  _deleteTransaction(int id){
    int indexToDelete = displayedTransactions.indexWhere((t)=> id == t.id);
    setState(() {
      _animatedListKey.currentState.removeItem(indexToDelete, (context, animation){
        return SizedBox();
      });
      transactions.removeWhere((t)=> id == t.id);
      displayedTransactions.removeWhere((t)=> id == t.id);
      saveData(transactions);
    });
  }
  
  void _startNewTransaction(BuildContext context)
  {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (bContext){ return NewTransaction(_addNewTransaction, null);}, backgroundColor: Theme.of(context).primaryColor);
  }

  void _viewStats(BuildContext context)
  {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (bContext){ return ExpensesOverview(transactions);}, backgroundColor: Theme.of(context).primaryColor);
  }

  @override
  Widget build(BuildContext context)
  { 
    _dropDownItems = buildList(_months);
    final mediaQuery = MediaQuery.of(context);
    final isLanscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS 
    ? CupertinoNavigationBar(middle: const Text('Expense Helper'), trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[GestureDetector(onTap: () => _startNewTransaction(context), child: Icon(CupertinoIcons.add),)],),) 
    : AppBar(title: const Text('Expense Helper'), actions: <Widget>[IconButton(icon: Icon(Icons.add), onPressed: () => _startNewTransaction(context))],);
    final transactionListWidget = Container(height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *.7, child: SlideTransition(position: _offsetAnimationList, child: TransactionList(displayedTransactions, _deleteTransaction, selectedMonth.value, _offsetAnimationList, _animatedListKey)));
    final body = SafeArea(child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
          alignment: Alignment.topCenter,
          
          child: ConfettiWidget(
            confettiController: _controllerTopCenter,
            blastDirection: pi / 2,
            maxBlastForce: 5, // set a lower max blast force
            minBlastForce: 2, // set a lower min blast force
            emissionFrequency: 0.05,
            numberOfParticles: 30, // a lot of particles at once
            gravity: .3,
          ),
        ),
         if(!isLanscape)Container(margin: EdgeInsets.only(right: mediaQuery.size.width *.06, left: mediaQuery.size.width *.06), height: mediaQuery.size.height *.05, padding: EdgeInsets.only(top: 2), alignment: Alignment.topCenter, child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: <Widget>[
             (Platform.isIOS ? Container(width:200,height:100,child:CupertinoPicker(scrollController: FixedExtentScrollController(initialItem: selectedMonth.value - 1), backgroundColor: Colors.white,itemExtent: 30, onSelectedItemChanged: (int index){onChangeMonths(_months[index]);}, children: List<Widget>.generate(12, (index){return new Center(child: Text('${_months[index].name}'));}))): DropdownButton(value: selectedMonth, items: _dropDownItems, onChanged: onChangeMonths)),
             //Text('<Month>', style: Theme.of(context).textTheme.title),
             Row(children: <Widget>[
                Container(padding: EdgeInsets.all(5), child: Image.asset('assets/images/money-coin-label-simple.png', fit: BoxFit.cover)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  child: RichText(
                    key: ValueKey<int>(totalMonthExpenses.round()),
                    text: TextSpan(style:Theme.of(context).textTheme.title, 
                    children: <TextSpan>
                    [
                      TextSpan(text: "${formatCurrency.format(totalMonthExpenses)}", style: TextStyle(color: Theme.of(context).primaryColor)),

                    ])),
                )
                ],)
            ,
           ],
         )),
         if(isLanscape) Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text('Show Chart', style: Theme.of(context).textTheme.title,), Switch.adaptive(value: showChart, onChanged: (val){setState(() {showChart = val;});})],),
         if(!isLanscape && selectedMonth.value == DateTime.now().month) Container(height:(mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *.3, child: SlideTransition(position: _offsetAnimationChart, child: Chart(_recentTransactions.toList(), _addNewTransaction))),
         if(!isLanscape) Container(height:selectedMonth.value == DateTime.now().month ? (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *.6 : (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *.9, child: transactionListWidget),
         if(isLanscape) showChart 
         ? Container(height:(mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *.7, child: Chart(_recentTransactions.toList(), _addNewTransaction))
         : Column(
           children: <Widget>[
            
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DropdownButton(value: selectedMonth, items: _dropDownItems, onChanged: onChangeMonths),
                    //Text('<Month>', style: Theme.of(context).textTheme.title),
                   Row(children: <Widget>[
                      RichText(text: TextSpan(style:Theme.of(context).textTheme.title, 
                        children: <TextSpan>
                        [
                          TextSpan(text: "Total: ", style: TextStyle(color: Theme.of(context).textTheme.title.color)),
                          TextSpan(text: "${formatCurrency.format(totalMonthExpenses)}", style: TextStyle(color: Theme.of(context).primaryColor))
                        ]))
                ],),
                  ],
                ),
            ),             
             transactionListWidget,
           ],
         ),
             Align(
                  alignment: Alignment.bottomCenter,
                  child: ConfettiWidget(
                    confettiController: _controllerBottomCenter,
                     colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ],
                    blastDirection: -pi/2,
                    emissionFrequency: 0.03,
                    numberOfParticles: 30,
                    maxBlastForce: 100,
                    minBlastForce: 30,
                    blastDirectionality: BlastDirectionality.directional,
                    gravity: 0.3,
                    shouldLoop: false,
                  ),
        ),
         
        ],
       ),
      )
      );
    return Platform.isIOS ? CupertinoPageScaffold(child: body, navigationBar: appBar,) : Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: appBar,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Platform.isIOS || isLanscape ? Container() : FloatingActionButton(child: Image.asset('assets/images/money-coin.png', fit: BoxFit.cover,), onPressed: () => _startNewTransaction(context)),
      
    );
  }
}



