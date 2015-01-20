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
   It is being tested with version instantclient-basic-nt-12.1.0.1.0(32-bit and 64-bit) on Windows, instantclient_11_2(32-bit) on Linux and Mac.
   
   You need to have OCCI binaries in the path for extension to work. OCCI binaries architecture(32-bit vs 64-bit) should match your Dart architecture(dart.exe).

   Here is how sample path setting might look like on Windows 32-bit:
 ```shell
 set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%
 ```
   on Windows 64-bit
 ```shell
 set path=%userprofile%\Downloads\instantclient-basic-windows.x64-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\Downloads\instantclient-basic-windows.x64-12.1.0.1.0\instantclient_12_1;%path%
 ```
   on Linux
 ```shell
 export LD_LIBRARY_PATH=~/Downloads/instantclient_11_2
 ```
   or on Mac
 ```shell
 export DYLD_LIBRARY_PATH=~/Downloads/instantclient_11_2-2
 ```

3.  Windows extension comes in 32-bit and 64-bit flavor, with 32-bit being selected by default. If you want to use 64-bit, then once you do 'pub get', you need to go to your project's packages\oracledart folder and rename oracledart_native_extension.dll to oracledart_native_extension_ia32.dll(for backup purposes), and rename oracledart_native_extension_x64.dll to oracledart_native_extension.dll.

4. On Windows Oracle Instant Client requires some form of Microsoft VC++ runtime present on the machine. Simplest would be to install VC redistributable package x86 from http://www.microsoft.com/en-us/download/details.aspx?id=30679.

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
