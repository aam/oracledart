library oracledart;

import 'dart:async';
import 'oracledart_synchronous_extension.dart';

Future<OracleConnection> connect(String username, String password, String db) {
  return new Future<OracleConnection>( 
      () => new OracleConnection.connect(username, password, db) );
  }
