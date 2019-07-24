import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_source/text/text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: TextDemo(),
    );
  }
}

class TextDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WidgetSpan"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: RichText(
          text: TextSpan(
            text: "hi",
            children: [
              WidgetSpan(child: Icon(Icons.ac_unit)),
              WidgetSpan(child: Icon(Icons.ac_unit)),
              WidgetSpan(child: Icon(Icons.ac_unit)),
              WidgetSpan(
                child: FlatButton(
                  onPressed: () {
                    print("click button");
                  },
                  child: Text("tap me"),
                ),
              ),
              TextSpan(
                text: "Focus here",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print("Focus here");
                  },
              ),
            ],
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  text: "你asdadasdasad好",
                  children: [
                    WidgetSpan(child: Icon(Icons.ac_unit)),
                    WidgetSpan(
                      child: FlatButton(
                        onPressed: () {
                          print("点击按钮");
                        },
                        child: Text("点我"),
                      ),
                    ),
                    TextSpan(
                      text: "这是什么啦啦啦是什么啦啦啦是什么啦啦啦是什么啦啦啦是什么啦啦啦是什么啦啦啦是什么啦啦啦",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print("点击事件");
                        },
                    ),
                  ],
                  style: Theme.of(context).textTheme.display1,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print("父类点击事件");
                    }),
            ),
            Container(
              color: Colors.red,
              child: LayoutDemo(
                children: <Widget>[
                  Icon(Icons.ac_unit),
                  Icon(Icons.link),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
