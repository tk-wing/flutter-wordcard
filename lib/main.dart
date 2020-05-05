import 'package:flutter/material.dart';
import 'package:my_own_wordcard/db/database.dart';
import 'package:my_own_wordcard/home_screen.dart';

MyDataBase database;

void main(){
  database = MyDataBase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '私だけの単語帳',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Lanobe',
      ),
      home: HomeScreen(),
    );
  }
}
