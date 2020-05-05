import 'package:flutter/material.dart';
import 'package:flutter_wordcard/db/database.dart';
import 'package:flutter_wordcard/main.dart';

enum TestStatus {
  BEFORE,
  START,
  ANSWER,
  FINISH,
}

class TestScreen extends StatefulWidget {
  final bool isInclMemorized;

  TestScreen({@required this.isInclMemorized});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _textQuestion = '問題';
  String _textAnswer = 'こたえ';
  bool _isMemorize = false;
  List<Word> _words = List();
  TestStatus _status;

  bool _isShowQuestion = false;
  bool _isShowAnswer = false;
  bool _isShowCheckBox = false;
  bool _isShowActionButton = false;

  int _index = 0;
  Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getWords();
  }

  Future<void> _getWords() async {
    if (widget.isInclMemorized) {
      _words = await database.allWords;
    } else {
      _words = await database.allWordsWithoutMemorize;
    }

    _words.shuffle();
    _status = TestStatus.BEFORE;

    setState(() {
      _isShowActionButton = true;
      _numberOfQuestion = _words.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('かくにんテスト'),
        centerTitle: true,
      ),
      floatingActionButton: _isShowActionButton
          ? FloatingActionButton(
              onPressed: () => _toNext(),
              child: Icon(Icons.skip_next),
              tooltip: '次へ',
            )
          : null,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              _numberOfQuestionPart(),
              SizedBox(height: 20.0),
              _questionCardPart(),
              SizedBox(height: 20.0),
              _answerCardPart(),
              SizedBox(height: 10.0),
              _isMemorizedCheckPart(),
            ],
          ),
          _finishMessage(),
        ],
      ),
    );
  }

  void _toNext() async {
    switch (_status) {
      case TestStatus.BEFORE:
        _status = TestStatus.START;
        _showQuestion();
        break;
      case TestStatus.START:
        _status = TestStatus.ANSWER;
        _showAnswer();
        break;
      case TestStatus.ANSWER:
        await _updateMemorizeFlag();
        if (_numberOfQuestion <= 0) {
          _status = TestStatus.FINISH;
          _showFinish();
        } else {
          _status = TestStatus.START;
          _showQuestion();
        }
        break;
      default:
    }
  }

  //TODO 残り問題数表示
  Widget _numberOfQuestionPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'のりこ問題数',
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(width: 25.0),
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        )
      ],
    );
  }

  //TODO 問題カード表示
  Widget _questionCardPart() {
    if (!_isShowQuestion) {
      return Container();
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/images/image_flash_question.png'),
        Text(
          _textQuestion,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  //TODO 答えカード表示
  Widget _answerCardPart() {
    if (!_isShowAnswer) {
      return Container();
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/images/image_flash_answer.png'),
        Text(
          _textAnswer,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  //TODO 暗記有無チェック
  Widget _isMemorizedCheckPart() {
    if (!_isShowCheckBox) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: CheckboxListTile(
        title: Text(
          '暗記済にする場合はチェックを入れて下さい',
          style: TextStyle(fontSize: 12.0),
        ),
        value: _isMemorize,
        onChanged: (value) => {
          setState(() {
            _isMemorize = value;
          })
        },
      ),
    );
  }

  //テスト終了メッセージ
  Widget _finishMessage() {
    if(_status != TestStatus.FINISH){
      return Container();
    }
    return Center(
      child: Text(
        'テスト終了',
        style: TextStyle(fontSize: 50.0),
      ),
    );

  }

  void _showQuestion() {
    _currentWord = _words[_index];
    setState(() {
      _textQuestion = _currentWord.strQuestion;
      _isMemorize = _currentWord.isMemorized;
      _isShowQuestion = true;
      _isShowAnswer = false;
      _isShowCheckBox = false;
    });
    _numberOfQuestion--;
    _index++;
  }

  void _showAnswer() {
    setState(() {
      _textAnswer = _currentWord.strAnswer;
      _isMemorize = _currentWord.isMemorized;
      _isShowAnswer = true;
      _isShowCheckBox = true;
    });
  }

  Future<void> _updateMemorizeFlag() async {
    var updateWord = Word(
      strQuestion: _currentWord.strQuestion,
      strAnswer: _currentWord.strAnswer,
      isMemorized: _isMemorize,
    );
    await database.updateWord(updateWord);
  }

  void _showFinish() {
    setState(() {
      _isShowActionButton = false;
    });
  }
}
