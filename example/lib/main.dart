import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_sqlcipher/native_sqlcipher.dart';
import 'package:native_sqlcipher/database.dart' as sqlite;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  sqlite.Database d1;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await NativeSqlcipher.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              FlatButton(
                child: Text("Test"),
                onPressed: OnTestClicked,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> OnTestClicked() async {
    print("clicked test");
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "t.db");
    print("opening $dbPath");
    d1 = sqlite.Database(dbPath, "helloworld");

    d1.execute("""
      create table if not exists foo(
        id integer primary key autoincrement,
        name text,
        content blob
      );
    """);
    d1.execute("""
      insert into foo(name, content) values('riguz', x'CAFEBABE');
    """);
    sqlite.Result r = d1.query("select id, name, content from foo;");
    try {
      for (sqlite.Row x in r) {
        int id = x.readColumnAsInt("id");
        String name = x.readColumnAsText("name");
        var content = x.readColumnAsBytes("content");
        print("-> $id, $name, $content");
      }
    } finally {
      r.close();
      d1.close();
    }
  }
}
