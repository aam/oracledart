Goal
---
Allows server-side Dart access Oracle server.

Available as pub package http://pub.dartlang.org/packages/oracledart.

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

This extension requires Oracle Instant Client being present on the machine.
It is being tested with version instantclient-basic-nt-12.1.0.1.0.

You need to have OCCI binaries in the path for extension to work.
Here is how sample path setting might look like:

```shell
set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%
```

To Build
---

- Put https://github.com/aam/oracledart/blob/master/.gclient into locally created folder and execute "gclient sync"
- Execute tools/build.py

Automated testing
---

Automated test is running at http://buildbot.aprelev.com:8009/waterfall.

Tests are automatically executed on three platforms: Windows, Ubuntu and Mac on every commit into dart bleeding_edge branch and every commit into OracleDart git repository.
