import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:flutter_wordcard/db/database.dart';
import 'package:flutter_wordcard/main.dart';
import 'package:flutter_wordcard/word_list_screen.dart';
import 'package:toast/toast.dart';

enum RegisterStatus { ADD, EDIT }

class WordRegisterScreen extends StatefulWidget {
  final RegisterStatus status;
  final Word word;

  WordRegisterScreen({
    @required this.status,
    this.word,
  });

  @override
  _WordRegisterScreenState createState() => _WordRegisterScreenState();
}

class _WordRegisterScreenState extends State<WordRegisterScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  String _title = '';

  @override
  void initState() {
    super.initState();
    if (widget.status == RegisterStatus.EDIT) {
      _title = '登録した単語の修正';
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    } else {
      _title = '新しい単語の追加';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () => _onWordRegisterd(),
              icon: Icon(Icons.done),
              tooltip: '登録',
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Center(
                child: Text(
                  '問題とこたえを入力して「登録」ボタンを押して下さい',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(height: 30.0),
              //問題入力部分
              _questionInputPart(),
              SizedBox(height: 100.0),
              //こたえ入力部分
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            '問題',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 10.0),
          TextField(
            enabled: RegisterStatus.ADD == widget.status,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            'こたえ',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Future<bool> _backToWordScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  Future<void> _insertword(Word word) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: Text('登録'),
              content: Text('登録してもいいですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () async {
                    try {
                      await database.addWord(word);
                      questionController.clear();
                      answerController.clear();
                      Toast.show('登録が完了がしました。', context,
                          duration: Toast.LENGTH_LONG);
                    } on SqliteException catch (e) {
                      Toast.show('この問題は既に登録されています。', context,
                          duration: Toast.LENGTH_LONG);
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  Future<void> _updateWord(Word word) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: Text("${word.strQuestion} の変更"),
              content: Text('変更してもいいですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () async {
                    try {
                      await database.updateWord(word);
                    } on SqliteException catch (e) {
                      Toast.show('エラーが発生しました。', context,
                          duration: Toast.LENGTH_LONG);
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  Future<void> _onWordRegisterd() async {
    if (questionController.text == '' || answerController.text == '') {
      Toast.show('問題と答えの両方を入力しないと登録できません。', context,
          duration: Toast.LENGTH_LONG);
      return;
    }

    var word = Word(
      strQuestion: questionController.text,
      strAnswer: answerController.text,
      isMemorized: false,
    );

    if (widget.status == RegisterStatus.EDIT) {
      await _updateWord(word);
      _backToWordScreen();
    } else {
      await _insertword(word);
    }
  }
}
