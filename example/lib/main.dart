import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_sqlcipher/native_sqlcipher.dart';
import 'package:native_sqlcipher/database.dart';
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
  Database d1;

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
          child:
          Column(
            children: [
              FlatButton(
                child: Text("Create"),
                onPressed: onCreatePressed,
              ),
              FlatButton(
                child: Text("Insert"),
                onPressed: onInsertPressed,
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: onDeletePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onCreatePressed() async {
    print("clicked test");
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "t.db");
    print("opening $dbPath");
    d1 = Database(dbPath, "helloworld");

    d1.execute("""
      create table t(id int not null primary key, name text);
    """);
    d1.close();
  }

  Future<void> onDeletePressed() async {
    print("clicked test");
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "t.db");
    print("opening $dbPath");
    d1 = Database(dbPath, "helloworld");
    d1.execute("""
      delete from t where id<10;
    """);
  }

  Future<void> onInsertPressed() async {
    print("clicked test");
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "t.db");
    print("opening $dbPath");
    d1 = Database(dbPath, "helloworld");

    d1.query("""
      select * from t;
    """);
  }
}
