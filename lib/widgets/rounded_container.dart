import 'package:flutter/material.dart';

class RoundedContainer extends Container{
  RoundedContainer({super.key, required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: super.build(context),
    );
  }
}