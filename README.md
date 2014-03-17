Bring Oracle to Dart
===

Goal
---
Allows server-side Dart access Oracle server.

Avialable as a pub package at http://pub.dartlang.org/packages/oracledart.

Sample
---
```dart
import 'package:oracledart/oracledart.dart';

void main() {
  print("Hello, World!");

  connect(
    "scott",
    "tiger",
    "(DESCRIPTION="
      "(ADDRESS=(PROTOCOL=TCP)(HOST=oracledb)(PORT=1521))"
      "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))")
    .then(
      (oracleConnection) {
        var resultset = oracleConnection.select("select job, avg(sal) from emp group by job");
        resultset.next();
        print(resultset.getString(1));
      },
      onError: (error) {
        print("Failed to connect: $error");
      });
}
```

produces

```shell
F:\dart-sdk\bin\dart.exe --enable-checked-mode --debug:53673 otest.dart
Hello, World!
CLERK
```

To Use
---

1. This extension is built with bleeding_edge of Dart. 
   Since Dart native extensions use C++ dart_api interface to integrate into Dart, they won't be necessarily compatible with older version of Dart.

2. This extension requires Oracle Instant Client being present on the machine.
   It is being tested with version instantclient-basic-nt-12.1.0.1.0 on Windows, instantclient_11_2 on Linux and Mac.

   You need to have OCCI binaries in the path for extension to work.

   Here is how sample path setting might look like on Windows:
```shell
set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%
```
   on Linux
```shell
export LD_LIBRARY_PATH=~/Downloads/instantclient_11_2
```
   or on Mac
```shell
export DYLD_LIBRARY_PATH=~/Downloads/instantclient_11_2-2
```

Source code
---

Complete source code including C++ modules is at https://github.com/aam/oracledart

To Build
---

- Put https://github.com/aam/oracledart/blob/master/.gclient into locally created folder and execute "gclient sync"
- Execute tools/build.py

Automated testing
---

Automated test is running at http://buildbot.aprelev.com:8009/waterfall.

Tests are automatically executed on three platforms: Windows, Ubuntu and Mac on every commit into dart bleeding_edge branch and every commit into OracleDart git repository.
