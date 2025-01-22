import 'package:app/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(initialRoute: '/', routes: {'/': (context) => Home()}));
}
