import 'package:flutter/material.dart';
import 'package:flutter_wordcard/db/database.dart';
import 'package:flutter_wordcard/main.dart';
import 'package:flutter_wordcard/word_register_screen.dart';
import 'package:toast/toast.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordList = List();
  bool _isSort = false;

  @override
  void initState() {
    super.initState();
    _getWordList();
  }

  _getWordList() async {
    _wordList = await database.allWords;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('単語一覧'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => _sortWords(),
            icon: Icon(Icons.sort),
            tooltip: 'ソート',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startWordRegistrerScreen(context),
        child: Icon(Icons.add),
        tooltip: '新しい単語の登録',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _wordListWodget(),
      ),
    );
  }

  void _startWordRegistrerScreen(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => WordRegisterScreen(
                  status: RegisterStatus.ADD,
                )));
  }

  Widget _wordListWodget() {
    return ListView.builder(
      itemCount: _wordList.length,
      itemBuilder: (context, int i) => _wordItem(i),
    );
  }

  Widget _wordItem(int i) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.grey.shade700,
      child: ListTile(
        title: Text(
          "${_wordList[i].strQuestion}",
        ),
        subtitle: Text(
          "${_wordList[i].strAnswer}",
          style: TextStyle(fontFamily: 'Mont'),
        ),
        trailing: _wordList[i].isMemorized ? Icon(Icons.check_circle) : null,
        onLongPress: () => _deleteWord(_wordList[i]),
        onTap: () => _editWord(_wordList[i]),
      ),
    );
  }

  Future<void> _deleteWord(Word word) async {
    await database.deleteWord(word);
    Toast.show('削除が完了しました', context);
    _getWordList();
  }

  void _editWord(Word word) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WordRegisterScreen(status: RegisterStatus.EDIT, word: word)));
  }

  Future<void> _sortWords() async{
    _wordList = await database.allWordsWithOrder(desc: _isSort);
    _isSort = _isSort ? false : true;
    setState(() {});
  }
}
