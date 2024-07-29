import 'package:flutter/material.dart';

class BankCardWidget extends StatelessWidget {
  const BankCardWidget({
    super.key, this.color, this.isLast, this.cardNum, this.cardProvider, this.cardExpDate, this.cardBalance,
  });
  final Color? color;
  final bool? isLast;
  final String? cardNum;
  final String? cardProvider;
  final String? cardExpDate;
  final String? cardBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: isLast! ? Colors.grey[100] : Colors.blue,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 25,
            offset: Offset(0, 25),
          ),
        ],
      ),
      child: isLast! ? 
      IconButton(
        icon: const Icon(Icons.add),
        color: Colors.grey[500],
        iconSize: 60,
        onPressed: () {},
      ):
      Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(0.9, 0.9),
            child: Text(
              cardProvider!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.25),
            child: Text(
              cardNum!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontFamily: 'Consolas',
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-0.9, 0.9),
            child: Text(
              cardExpDate!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
