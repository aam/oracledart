library oracledart_sync_extension_test;

import 'package:unittest/unittest.dart';

import 'package:oracledart/oracledart_synchronous_extension.dart';

void main() {
  for (var i = 0; i < 10; i++) {
      OracleConnection connection = new OracleConnection.connect(
        "scott",
        "tiger",
        "(DESCRIPTION="
          "(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))"
          "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");

    OracleResultset resultset =
        connection.select("select empno, ename from emp");
    test('Data Retrieval', () => expect(resultset.next(), true));
    while (resultset.next()) {
        print("${resultset.getInt(1)} ${resultset.getString(2)}");
    }

    resultset = connection.select("select job, avg(sal) from emp group by job");
    test('Another Data Retrieval', () => expect(resultset.next(), true));
    while (resultset.next()) {
        print("${resultset.getString(1)} "
              "${resultset.getDouble(2)} "
              "${resultset.getFloat(2)}");
    }

    OracleStatement stmt =
        connection.createStatement("select ename from emp where empno > :1");
    stmt.setInt(1, 7700);
    OracleResultset resultsetOver7700 = stmt.executeQuery();
    test('Last Data Retrieval', () => expect(resultsetOver7700.next(), true));
    while (resultsetOver7700.next()) {
        print("${resultsetOver7700.getString(1)}");
    }
  }
}
