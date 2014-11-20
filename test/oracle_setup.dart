library oracle_setup;

import 'dart:io';

class OracleSetup {
  var host;
  var port;

  OracleSetup.Establish() {
    var env = Platform.environment;
    host = env['ORACLE_HOST'];
    if (host == null) {
      host = "w8-32-12core";
    }
    port = env['ORACLE_PORT'];
    if (port == null) {
      port = "1521";
    }
  }
}