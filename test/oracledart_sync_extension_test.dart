library oracledart_sync_extension_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:oracledart/oracledart_synchronous_extension.dart';

void main() {
  useVMConfiguration();
  for (var i = 0; i < 10; i++) {
    OracleConnection connection = new OracleConnection.connect(
      "scott",
      "tiger",
      "(DESCRIPTION="
        "(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))"
        "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");

    test('Test getInt and getString', () {
      OracleResultset resultset =
          connection.select("select empno, ename from emp");
      var expected = [
        [7369, 'SMITH'],
        [7499, 'ALLEN'],
        [7521, 'WARD'],
        [7566, 'JONES'],
        [7654, 'MARTIN'],
        [7698, 'BLAKE'],
        [7782, 'CLARK'],
        [7788, 'SCOTT'],
        [7839, 'KING'],
        [7844, 'TURNER'],
        [7876, 'ADAMS'],
        [7900, 'JAMES'],
        [7902, 'FORD'],
        [7934, 'MILLER']];
      var counter = expected.length;
      for (var pair in expected) {
        expect(resultset.next(), equals(true));
        expect(resultset.getInt(1), equals(pair[0]));
        expect(resultset.getString(2), equals(pair[1]));
        counter--;
      }
      expect(counter, equals(0));
      expect(resultset.next(), equals(false));
    });
  
    test('Test getString, getDouble, getFloat', () {
      var expected = [
        ['CLERK', 1037.5, 1037.5],
        ['SALESMAN', 1400.0, 1400.0],
        ['PRESIDENT', 5000.0, 5000.0],
        ['MANAGER', 2758.333333333333, 2758.330078125],
        ['ANALYST', 3000.0, 3000.0]];    
      var resultset = connection.select("select job, avg(sal) from emp group by job");
      var counter = expected.length;
      for (var triple in expected) {
        expect(resultset.next(), equals(true));
        expect(resultset.getString(1), equals(triple[0]));
        expect(resultset.getDouble(2), closeTo(triple[1], 0.000000000001));
        expect(resultset.getFloat(2), closeTo(triple[2], 0.01));
        counter--;
      }
      expect(counter, equals(0));
      expect(resultset.next(), equals(false));
    });

    test('Test setInt', () {
      var expected = [
          'CLARK',
          'SCOTT',
          'KING',
          'TURNER',
          'ADAMS',
          'JAMES',
          'FORD',
          'MILLER'];                      
      OracleStatement stmt =
          connection.createStatement("select ename from emp where empno > :1");
      stmt.setInt(1, 7700);
      OracleResultset resultset = stmt.executeQuery();
      var counter = expected.length;
      for (var value in expected) {
        expect(resultset.next(), equals(true));
        expect(resultset.getString(1), equals(value));
        counter--;
      }
      expect(counter, equals(0));
      expect(resultset.next(), equals(false));
    });
  }
}
