// Copyright (c) 2014

library oracledart_asynchronous_extension;

import 'dart:async';
import 'dart:isolate';

import 'dart-ext:oracledart_extension';

// A class caches the native port used to call an asynchronous extension.
class Oracle {
  static SendPort _port;

  Future<bool> connect(String username, String password, String db) {
    var completer = new Completer();
    var replyPort = new RawReceivePort();
    var args = new List(4);
    args[0] = username;
    args[1] = password;
    args[2] = db;
    args[3] = replyPort.sendPort;
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        completer.complete(result);
      } else {
        completer.completeError(new Exception("Oracle creation failed"));
      }
    };
    return completer.future;
  }

  SendPort get _servicePort {
    if (_port == null) {
      _port = _newServicePort();
    }
    return _port;
  }

  SendPort _newServicePort() native "Oracle_ServicePort";
}
