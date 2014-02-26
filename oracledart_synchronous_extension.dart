// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart_synchronous_extension;

import 'dart-ext:oracledart_extension';
import 'dart:nativewrappers';

abstract class OracleConnection {
  factory OracleConnection.connect(String username,
                                   String password,
                                   String db) {
    return new _OracleConnection().._connect(username, password, db);
  }
  OracleStatement createStatement(String query);
  OracleResultset select(String query);
}

class _OracleConnection extends NativeFieldWrapperClass1
                        implements OracleConnection {
  int _connect(String username, String password, String db)
    native "OracleConnection_Connect";
  int _createStatement(OracleStatement statement, String query)
    native "OracleConnection_CreateStatement";

  OracleStatement createStatement(String query) {
    var statement = new _OracleStatement(this);
    _createStatement(statement, query);
    return statement;
  }

  OracleResultset select(String query) {
    var statement = new _OracleStatement(this);
    _createStatement(statement, query);
    return statement.executeQuery();
  }
}

abstract class OracleStatement {
  OracleResultset executeQuery();
  void setInt(int ndx, int value);
}

class _OracleStatement extends NativeFieldWrapperClass1
                       implements OracleStatement {
  OracleConnection connection;
  _OracleStatement(this.connection);

  int _execute(OracleResultset resultset) native "OracleStatement_Execute";
  OracleResultset executeQuery() {
    var resultset = new _OracleResultset(this);
    _execute(resultset);
    return resultset;
  }
  void setInt(int ndx, int value) native "OracleStatement_SetInt";
}

abstract class OracleResultset {
  int getInt(int index);
  String getString(int index);
  double getDouble(int index);
  double getFloat(int index);
  bool next();
}

class _OracleResultset extends NativeFieldWrapperClass1
                       implements OracleResultset {
  OracleStatement statement;
  _OracleResultset(this.statement);

  int getInt(int index) native "OracleResultset_GetInt";
  String getString(int index) native "OracleResultset_GetString";
  double getFloat(int index) native "OracleResultset_GetFloat";
  double getDouble(int index) native "OracleResultset_GetDouble";
  bool next() native "OracleResultset_Next";
}
