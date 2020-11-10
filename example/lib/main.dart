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
          child: FlatButton(
            child: Text("Test sqlite"),
            onPressed: onTestPressed,
          ),
        ),
      ),
    );
  }

  Future<void> onTestPressed() async {
    print("clicked test");
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "test1.db");
    print("opening $dbPath");
    Database d = Database(dbPath, "helloworld");
    d.execute("drop table if exists Cookies;");
    d.execute("drop table if exists email;");
    d.execute("""
      create table Cookies (
        id integer primary key autoincrement,
        name text not null,
        alternative_name text
      );""");
    d.execute("""
      CREATE VIRTUAL TABLE email USING fts5(sender, title, body);
    """);
    d.execute("""
      insert into Cookies values(null, 'a', 'b');
    """);
    int id = d.last_insert_rowid();
    print("inserted: $id");
    d.close();
  }
}
