// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_sample_extension;

import 'sample_synchronous_extension.dart';

void check(bool condition, String message) {
  if (!condition) {
    throw new StateError(message);
  }
}

void main() {
  for (var i = 0; i < 10; i++) {
    var connect_id = connect("scott", "tiger", "");
    print("Connect id $connect_id");
  }
}
