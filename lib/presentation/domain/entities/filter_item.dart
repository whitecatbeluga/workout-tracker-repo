import 'package:flutter/material.dart';

class FilterItem {
  final String title;
  Function onTap;
  final IconData? icon;

  FilterItem({required this.title, required this.onTap, this.icon});
}
