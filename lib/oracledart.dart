// Copyright (c) 2014, Alexander Aprelev.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library oracledart;

import 'dart:async';
import 'dart-ext:oracledart_extension';
import 'dart:nativewrappers';

part 'oracledart_synchronous_extension.dart';

Future<OracleConnection> connect(String username, String password, String db) {
  return new Future<OracleConnection>( 
      () => new OracleConnection.connect(username, password, db) );
  }
