
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:native_sqlcipher/sqlcipher.dart' as sqlite;
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
  sqlite.Database d1;

  @override
  void initState() {
    super.initState();
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
    d1 = sqlite.Database(dbPath);
    d1.execute("""
      drop table if exists foo;
    """);
    d1.execute("""
      create table if not exists foo(
        id integer primary key autoincrement,
        name text,
        content blob
      );
    """);
    d1.execute("""
      insert into foo(name, content) values('riguz', x'89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d49444154089963a8d7bef71f00053d0288b0402c1b0000000049454e44ae426082');
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
