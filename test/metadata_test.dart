import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:oracledart/oracledart.dart';

void main() {
  useVMConfiguration();
  OracleConnection connection = new OracleConnection.connect(
    "scott",
    "tiger",
    "(DESCRIPTION="
      "(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))"
      "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");

  test('Test getMetadataVector', () {
    OracleResultset resultset =
        connection.select("select empno, ename from emp");
    OracleMetadataVector metadata =
        resultset.getMetadataVector();
    expect(metadata.getSize(), equals(2));
  });
}
