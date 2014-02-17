// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_oracledart_sync_extension;

import 'oracledart_synchronous_extension.dart';

void check(bool condition, String message) {
  if (!condition) {
    throw new StateError(message);
  }
}

void main() {
  for (var i = 0; i < 10; i++) {
    OracleConnection connection = new OracleConnection.connect(
        "scott",
        "tiger",
        "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");

    OracleResultset resultset = connection.select("select empno, ename from emp");
    while (resultset.next()) {
        print("${resultset.getInt(1)} ${resultset.getString(2)}");
    }

    resultset = connection.select("select job, avg(sal) from emp group by job");
    while (resultset.next()) {
        print("${resultset.getString(1)} ${resultset.getDouble(2)} ${resultset.getFloat(2)}");
    }
  }
}
