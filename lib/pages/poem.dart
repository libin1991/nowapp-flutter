import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowapp_flutter/model/PoemModel.dart';
import 'package:nowapp_flutter/util/Api.dart';

class PoemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PoemFuture();
  }
}

class _PoemFuture extends StatefulWidget {
  @override
  _PoemFutureState createState() => _PoemFutureState();
}
class _PoemFutureState extends State<_PoemFuture> {
  Future future;
  @override
  void initState() {
    super.initState();
    future = loadData(0);
  }

  Future<PoemModel> loadData(int index) async {
    Map<String, dynamic> query = { 'index': index };
    final data = await ApiClient.request(Api.POEM, query);
    PoemModel poem = new PoemModel.fromJson(data);
    return poem;
  }
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      builder: (context, AsyncSnapshot async) {
        if (async.connectionState == ConnectionState.active ||
            async.connectionState == ConnectionState.waiting) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        }
        if (async.connectionState == ConnectionState.done) {
          if (async.hasError) {
            return new Center(
              child: new Text('服务器错误，请稍后重试'),
            );
          } else if (async.hasData) {
            var data = async.data;
            var _poem = data.content.poem;
            var _title = _poem.title.content;
            var _total = data.total;
            var _index = data.index;
            var _date = data.date;
            final double _height = MediaQuery.of(context).size.height;
            return new SingleChildScrollView(
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'Syst',
                    color: Color.fromRGBO(66, 66, 66, 1),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  child: new Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Positioned(
                              left: 10,
                              top: _height * 0.2,
                              child: new IconButton(
                                icon: Image.asset('assets/icon-left.png'),
                                onPressed: () {
                                  if (_index == 0) {
                                    Fluttertoast.showToast(
                                      msg: '已经是第一首',
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                    );
                                  } else {
                                    setState(() {
                                      future = loadData(_index - 1);
                                    });
                                  }
                                  
                                },
                              )
                            ),
                            Positioned(
                              right: 10,
                              top: _height * 0.4,
                              child: new IconButton(
                                icon: Image.asset('assets/icon-right.png'),
                                onPressed: () {
                                  if (_index > 0 && _index >= _total) {
                                    Fluttertoast.showToast(
                                      msg: '没有更多了',
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                    );
                                  } else {
                                    setState(() {
                                      future = loadData(_index + 1);
                                    });
                                  }
                                },
                              )
                            ),
                            new Column(
                              children: <Widget>[
                                new Container(
                                  margin: const EdgeInsets.only(top: 80),
                                  child: new Text(_title, style: TextStyle( fontSize: 20 )),
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                                  child:  new Text(_poem.author, style: TextStyle( fontSize: 14, color: Colors.black54 )),
                                ),
                                new Container(
                                  child: _poemClauses(context, data),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: new Text(_date, style: TextStyle( color: Colors.black45 )),
                      )
                      
                    ],
                  )
                ),
              ),
            );
          }
        }
      },
      future: future,
    );
  }
}

Widget _poemClauses(BuildContext context, PoemModel data) {
  // bool isInlineComment(content) {
  //   bool inline = true;
  //   for (int i = 0; i < content.length; i++) {
  //       if (content[i] >= "㐀" && content[i] <= "﨩") {
  //           inline = false;
  //           break;
  //       }
  //   }

  //   return inline;
  // }
  // String formatClause(clause) {
  //     String content = clause.content;
  //     if (clause.comments != null) {
  //       for (int j = clause.comments.length - 1; j >= 0; j-=1) {
  //         var comment = clause.comments[j];
  //         if (comment.type != 'Text') {
  //           continue;
  //         }
  //         if (isInlineComment(comment.content)) {
  //           content = content.substring(0, comment.index) + comment.content + content.substring(comment.index);
  //         }
  //       }
  //     }
  //     return content;
  // }
  var _poem = data.content.poem;
  var _clauses = _poem.clauses;
  List<Widget> _poems = [];
  List<Text> _poemClauses = [];
  if (_clauses != null) {
    for (int i = 0, len = _clauses.length; i < len; i += 1) {
      var _clause = _clauses[i];
      var content = _clause.content;
      _poemClauses.add(new Text(content));
      
      bool isBreak = _clause.breakAfter != null && _clause.breakAfter != false;
      bool isDivided = _poem.isTwoClausesPerSentence && i % 2 == 1;
      bool isEndMark = '。；！？'.indexOf(_clause.content.substring(_clause.content.length - 1)) >= 0;
      if ((isDivided || isEndMark)|| isBreak)
      {
        _poems.add(new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _poemClauses,
        ));
        _poemClauses = [];
      }
    }
  }
  return new Column(
    children: _poems,
  );
}