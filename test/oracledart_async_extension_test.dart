library oracledart_sync_extension_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:oracledart/oracledart_asynchronous_extension.dart';

void main() {
  useVMConfiguration();

  Oracle oracle = new Oracle();
  oracle.connect(
    "scott",
    "tiger",
    "(DESCRIPTION="
      "(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))"
      "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))").then((result) {
    print("Got result $result");
  });
  print("Send connect request");
}

