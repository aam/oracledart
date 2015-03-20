import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:oracledart/oracledart.dart';

import 'oracle_setup.dart';

void main() {
  var oracle = new OracleSetup.Establish();

  useVMConfiguration();
  OracleConnection connection = new OracleConnection.connect(
    "scott",
    "tiger",
    "(DESCRIPTION="
      "(ADDRESS=(PROTOCOL=TCP)(HOST=${oracle.host})(PORT=${oracle.port}))"
      "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");

  test('Test getMetadataVector', () {
    OracleResultset resultset =
        connection.select("select empno, ename from emp");
    OracleMetadataVector metadata =
        resultset.getMetadataVector();
    expect(metadata.getSize(), equals(2));
    expect(metadata.getColumnName(0), equals("EMPNO"));
    expect(metadata.getColumnName(1), equals("ENAME"));
  });

  test('Test getMetadataVector with star', () {
    OracleResultset resultset =
        connection.select("select * from emp");
    OracleMetadataVector metadata =
        resultset.getMetadataVector();
    expect(metadata.getSize(), equals(8));
    expect(metadata.getColumnName(0), equals("EMPNO"));
    expect(metadata.getColumnName(1), equals("ENAME"));
    expect(metadata.getColumnName(2), equals("JOB"));
    expect(metadata.getColumnName(3), equals("MGR"));
    expect(metadata.getColumnName(4), equals("HIREDATE"));
    expect(metadata.getColumnName(5), equals("SAL"));
    expect(metadata.getColumnName(6), equals("COMM"));
    expect(metadata.getColumnName(7), equals("DEPTNO"));
  });

  test('Test getMetadataVector iterating through columns', () {
    OracleResultset resultset =
        connection.select("select * from emp order by empno");
    OracleMetadataVector metadata = resultset.getMetadataVector();
    var columns = {};
    for (int i = 0; i < metadata.getSize(); i++) {
      columns[metadata.getColumnName(i)] = i + 1;
    }
    resultset.next();
    expect(resultset.getString(columns["ENAME"]), "SMITH");
    expect(resultset.getString(columns["JOB"]), "CLERK");
  });

  test('Test getStringByName, getIntByName', () {
    OracleResultset resultset =
        connection.select("select empno, ename from emp where EMPNO='7369'");
    resultset.next();
    expect(resultset.getString(1), equals("7369"));
    expect(resultset.getStringByName("EMPNO"), equals("7369"));
    expect(resultset.getInt(1), equals(7369));
    expect(resultset.getIntByName("EMPNO"), equals(7369));
    expect(resultset.getString(2), equals("SMITH"));
    expect(resultset.getStringByName("ENAME"), equals("SMITH"));
  });

  test('Fail to getString with invalid column name', () {
    OracleResultset resultset =
        connection.select("select empno, ename from emp where EMPNO='7369'");
    resultset.next();
    expect(() => resultset.getStringByName("empno"),
      throwsA((e) => e.toString() == 'Exception: Column "empno" not found'));
  });
}
