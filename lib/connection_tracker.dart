import 'dart:ffi';

import 'package:native_sqlcipher/database.dart';

/// Copied from moor
/// This entire file is an elaborate hack to workaround https://github.com/simolus3/moor/issues/835.
///
/// Users were running into database deadlocks after (stateless) hot restarts
/// in Flutter when they use transactions. The problem is that we don't have a
/// chance to call `sqlite3_close` before a Dart VM restart, the Dart object is
/// just gone without a trace. This means that we're leaking sqlite3 database
/// connections on restarts.
/// Even worse, those connections might have a lock on the database, for
/// instance if they just started a transaction.
///
/// Our solution is to store open sqlite3 database connections in an in-memory
/// sqlite database which can survive restarts! For now, we keep track of the
/// pointer of an sqlite3 database handle in that database.
/// At an early stage of their `main()` method, users can now use
/// `VmDatabase.closeExistingInstances()` to release those resources.

/// Copied from https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/lib/src/database_tracker.dart

class ConnectionTracker {
  final Database _trackingDb;

  static const int OPEN = 0;
  static const int CLOSED = 1;
  static const int FORCE_CLOSED = -1;

  static ConnectionTracker _instance;

  static ConnectionTracker get instance =>
      _instance ??= ConnectionTracker._internal();

  ConnectionTracker._internal()
      : _trackingDb = Database(
            "file:connection_tracker?mode=memory&cache=shared",
            "ConnectionTracker") {
    _initializeDb();
  }

  void markOpen(int ptr) {
    final String now = DateTime.now().toIso8601String();
    _trackingDb.execute(
        "insert into connections(ptr, status, created_time) values($ptr, 0, '$now');");
  }

  void markClosed(int ptr) {
    final String now = DateTime.now().toIso8601String();
    _trackingDb.execute(
        "update connections set status=$CLOSED, closed_time='$now' where ptr=$ptr");
  }

  void _initializeDb() {
    _trackingDb.execute("""
    create table if not exists connections
    (
      ptr integer primary key not null,
      status int,
      created_time text,
      closed_time text
    );
    """);
  }

  void forceCloseExisting() {
    _trackingDb.execute("begin;");
    final String now = DateTime.now().toIso8601String();
    try {
      Result result =
          _trackingDb.query("select ptr from connections where status <> 0;");
      for (Row row in result) {
        int address = row.readColumnAsInt("ptr");
        print("Database connection GC detected at $address.");
        Database.fromPointer(Pointer.fromAddress(address).cast())..close();

        _trackingDb.execute(
            "update connections set status=$FORCE_CLOSED, closed_time='$now' where ptr=$address");
      }
    } finally {
      _trackingDb.execute("commit;");
    }
  }
}
