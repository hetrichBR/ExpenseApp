import 'package:flutter/material.dart';
class Month{
  int value;
  String name;

  Month(this.value, this.name);

   static List<Month> getMonths()
   {
       return <Month>[
         Month(1, "January"),
         Month(2, "February"),
         Month(3, "March"),
         Month(4, "April"),
         Month(5, "May"),
         Month(6, "June"),
         Month(7, "July"),
         Month(8, "August"),
         Month(9, "September"),
         Month(10, "October"),
         Month(11, "November"),
         Month(12, "December"),
       ];
   }
}

class MonthListDropdownButton extends StatefulWidget {
  @override
  _MonthListDropdownButtonState createState() => _MonthListDropdownButtonState();
}

class _MonthListDropdownButtonState extends State<MonthListDropdownButton> {
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
        selectedMonth = selection;
        print(selectedMonth);
    });
  }


  @override
  Widget build(BuildContext context) {
    _dropDownItems = buildList(_months);
    return Container(child: DropdownButton(value: selectedMonth, items: _dropDownItems, onChanged: onChangeMonths));
  }
}