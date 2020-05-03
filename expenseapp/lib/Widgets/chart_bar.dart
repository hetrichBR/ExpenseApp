import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {

  final String label;
  final double spendingAmount;
  final double spendingPercentage;

  ChartBar(this.label, this.spendingAmount, this.spendingPercentage);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints){
       return Column(
      children: <Widget>[
        Container(height: constraints.maxHeight * .15, child: FittedBox(child: Text('\$${spendingAmount.toStringAsFixed(0)}'))),
        SizedBox(height: constraints.maxHeight * .05,),
        Container(
          height: constraints.maxHeight * .6,
          width: 10,
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
            Container(decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              color: Color.fromRGBO(220, 220, 220, 1),
              borderRadius: BorderRadius.circular(10)
             ),
            ),
            FractionallySizedBox(
              heightFactor: spendingPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(10)),
                  ),
              ),
          ],
          ),
        ),
        SizedBox(height: constraints.maxHeight * .05,),
        Container(height: constraints.maxHeight * .15, child: FittedBox(child: Text(label)))
      ],
    );
    }); 
  }
}