// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart_synchronous_extension;

import 'dart-ext:oracledart_extension';
import 'dart:nativewrappers';

abstract class OracleConnection {
    factory OracleConnection.connect(string username, string password, string db) {
        var connection = new _OracleConnection();
        connection._connect(username, password, db);
        return connection;
    }
    int select(string query);
}

class _OracleConnection extends NativeFieldWrapperClass1 implements OracleConnection {
    int _connect(string username, string password, string db) native "OracleConnection_Connect";
    int _select(OracleResultset resultset, string query) native "OracleConnection_Select";

    OracleResultset select(string query) {
        var resultset = new _OracleResultset();
        _select(resultset, query);
        return resultset;
    }
}

abstract class OracleResultset {
    int getInt(int index);
    String getString(int index);
    bool next();
}

class _OracleResultset extends NativeFieldWrapperClass1 implements OracleResultset {
    int getInt(int index) native "OracleResultset_GetInt";
    String getString(int index) native "OracleResultset_GetString";
    bool next() native "OracleResultset_Next";
}
