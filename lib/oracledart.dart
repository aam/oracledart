// Copyright (c) 2014, Alexander Aprelev.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart;

import 'dart:async';
import 'dart:collection';

import 'package:oracledart/src/oracledart_native.dart';

Future<OracleConnection> connect(String username, String password, String db) {
  return new Future<OracleConnection>(
      () => new OracleConnection.connect(username, password, db));
  }

abstract class OracleConnection {
  factory OracleConnection.connect(String username,
                                   String password,
                                   String db) {
    return new OracleConnectionNative()..connect(username, password, db);
  }
  OracleStatement createStatement(String query);
  OracleResultset select(String query);
}

abstract class OracleStatement {
  OracleResultset executeQuery();
  void setInt(int ndx, int value);
  void setString(int ndx, String value);
}

class OracleValue {
  OracleResultset resultset;

  OracleValue._fromResultset(this.resultset);

  getInt(int index) => resultset.getInt(index);
  String getString(int index) => resultset.getString(index);
  getDouble(int index) => resultset.getDouble(index);
  getFloat(int index) => resultset.getFloat(index);
  getClob(int index) => resultset.getClob(index);
}

class OracleIterator implements Iterator<OracleValue> {
  OracleResultset resultset;
  OracleIterator.fromResultset(this.resultset);

  bool moveNext() => resultset.next();
  get current => new OracleValue._fromResultset(resultset);
}

abstract class OracleResultset extends Object with IterableMixin<OracleValue> {
  int getInt(int index);
  String getString(int index);
  double getDouble(int index);
  double getFloat(int index);
  ByteBuffer getClob(int index);
  bool next();

  OracleMetadataVector getMetadataVector();

  int getIntByName(String columnName);
  String getStringByName(String columnName);
  double getFloatByName(String columnName);
  double getDoubleByName(String columnName);
}

abstract class OracleMetadataVector {
  int getSize();
  String getColumnName(int index);
}
