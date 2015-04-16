// Copyright (c) 2014, Alexander Aprelev.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart_native;

import 'dart:nativewrappers';
import 'dart-ext:oracledart_native_extension';
import 'package:oracledart/oracledart.dart';

class OracleConnectionNative extends NativeFieldWrapperClass1
                        implements OracleConnection {
  void connect(String username, String password, String db)
    native "OracleConnection_Connect";
  void _createStatement(OracleStatement statement, String query)
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
  void setString(int ndx, String value) native "OracleStatement_SetString";
}

class _OracleResultset extends NativeFieldWrapperClass1
                       implements OracleResultset {
  OracleIterator get iterator => new OracleIterator.fromResultset(this);

  OracleStatement statement;
  _OracleResultset(this.statement);

  int getInt(int index) native "OracleResultset_GetInt";
  String getString(int index) native "OracleResultset_GetString";
  double getFloat(int index) native "OracleResultset_GetFloat";
  double getDouble(int index) native "OracleResultset_GetDouble";
  ByteBuffer getClob(int index) native "OracleResultset_GetClob";
  bool next() native "OracleResultset_Next";

  void _getMetadataVector(OracleMetadataVector metadataVector)
      native "OracleResultset_GetMetadataVector";

  _OracleMetadataVector metadataVector;
  OracleMetadataVector getMetadataVector() {
    if (metadataVector == null) {
      metadataVector = new _OracleMetadataVector();
      _getMetadataVector(metadataVector);
    }
    return metadataVector;
  }

  Map<String, int> columnsByName;
  int getColumnIndexByName(String columnName) {
    if (columnsByName == null) {
      columnsByName = {};
      OracleMetadataVector metadata = getMetadataVector();
      for (int i = 0; i < metadata.getSize(); i++) {
        columnsByName[metadata.getColumnName(i)] = i + 1;
      }
    }
    var index = columnsByName[columnName];
    if (index == null) {
      throw new Exception('Column "$columnName" not found');
    }
    return index;
  }
  int getIntByName(String columnName) {
    return getInt(getColumnIndexByName(columnName));
  }
  String getStringByName(String columnName) {
    return getString(getColumnIndexByName(columnName));
  }
  double getFloatByName(String columnName) {
    return getFloat(getColumnIndexByName(columnName));
  }
  double getDoubleByName(String columnName) {
    return getDouble(getColumnIndexByName(columnName));
  }
}

class _OracleMetadataVector extends NativeFieldWrapperClass1
                            implements OracleMetadataVector {
  int getSize() native "OracleMetadataVector_GetSize";
  String getColumnName(int index) native "OracleMetadataVector_GetColumnName";
}
