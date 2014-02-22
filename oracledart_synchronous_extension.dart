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
    OracleResultset select(String query);
}

class _OracleConnection extends NativeFieldWrapperClass1
                        implements OracleConnection {
    int _connect(String username, String password, String db)
        native "OracleConnection_Connect";
    int _select(OracleResultset resultset, String query)
        native "OracleConnection_Select";

    OracleResultset select(String query) {
        var resultset = new _OracleResultset();
        _select(resultset, query);
        return resultset;
    }
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
    int getInt(int index) native "OracleResultset_GetInt";
    String getString(int index) native "OracleResultset_GetString";
    double getFloat(int index) native "OracleResultset_GetFloat";
    double getDouble(int index) native "OracleResultset_GetDouble";
    bool next() native "OracleResultset_Next";
}
