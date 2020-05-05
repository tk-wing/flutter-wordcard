import 'package:flutter/material.dart';
import 'package:flutter_wordcard/components/button_with_icon.dart';
import 'package:flutter_wordcard/test_screen.dart';
import 'package:flutter_wordcard/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isInclMemorized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Expanded(child: Image.asset('assets/images/image_title.png')),
          _titleText(),
          Divider(
            height: 30.0,
            color: Colors.white,
            indent: 8.0,
            endIndent: 8.0,
          ),
          // テストボタン
          ButtonWithIcon(
            onPressed: () => _startTestScreen(context),
            icon: Icon(Icons.play_arrow),
            label: 'かくにんテストをする',
            color: Colors.orange,
          ),
          SizedBox(height: 10.0),
          // ラジオボタン
          _radioButtons(),
          SizedBox(height: 30.0),
          // 単語一覧ボタン
          ButtonWithIcon(
            onPressed: () => _startWordListScreen(context),
            icon: Icon(Icons.list),
            label: '単語一覧を見る',
            color: Colors.grey,
          ),
          SizedBox(height: 30.0),
          Text(
            'powered by tk-wing 2020',
            style: TextStyle(fontFamily: 'Mont'),
          ),
          SizedBox(height: 16.0),
        ],
      )),
    );
  }

  void _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  void _startTestScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen(isInclMemorized: isInclMemorized)));
  }

  Widget _titleText() {
    return Column(
      children: <Widget>[
        Text('私だけの単語帳', style: TextStyle(fontSize: 40.0)),
        Text('My Own Frashcard',
            style: TextStyle(fontSize: 24.0, fontFamily: 'Mont')),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: <Widget>[
          RadioListTile<bool>(
            groupValue: isInclMemorized,
            title: Text(
              '暗記済みの単語を除外する',
              style: TextStyle(fontSize: 16.0),
            ),
            value: false,
            onChanged: (value) => _onRadioSelected(value),
          ),
          RadioListTile<bool>(
            groupValue: isInclMemorized,
            title: Text(
              '暗記済みの単語を含む',
              style: TextStyle(fontSize: 16.0),
            ),
            value: true,
            onChanged: (value) => _onRadioSelected(value),
          ),
        ],
      ),
    );
  }

  void _onRadioSelected(bool value) {
    setState(() {
      isInclMemorized = value;
    });
  }
}
