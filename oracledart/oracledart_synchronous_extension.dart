// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart_synchronous_extension;

import 'dart-ext:oracledart_extension';
import 'dart:nativewrappers';

class OracleConnection extends NativeFieldWrapperClass1 {
}

class OracleResultset extends NativeFieldWrapperClass1 {
    int getInt(int index) native "OracleResultset_GetInt";
    String getString(int index) native "OracleResultset_GetString";
    bool next() native "OracleResultset_Next";

}

int connect(OracleConnection connection,
            string username,
            string password,
            string db) native "Connect";
int select(OracleConnection connection,
           OracleResultset resultset,
           string query) native "Select";
