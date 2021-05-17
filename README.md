# native_sqlcipher

Flutter sqlcipher plugin, for using sqlcipher in both Android and iOS by dart:ffi. The implementations are copied from [dart ffi example](https://github.com/dart-lang/sdk/tree/master/samples/ffi/sqlite). However there're a few changes made:

* Use sqlcipher(sqlite 3.31.0) instead of sqlite
* Added support to both Android and iOS platform
* Additional apis are added
 
This plugin is mainly created to support secure storage in [Okapia app](https://github.com/drriguz/ben).

Please refer [example/lib/main.dart](example/lib/main.dart) for usage.



