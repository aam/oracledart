// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include <occi.h>

#include "include/dart_api.h"
#include "include/dart_native_api.h"

Dart_NativeFunction ResolveName(Dart_Handle name,
                                int argc,
                                bool* auto_setup_scope);

DART_EXPORT Dart_Handle oracledart_extension_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) { return parent_library; }

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName);
  if (Dart_IsError(result_code)) return result_code;

  return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) Dart_PropagateError(handle);
  return handle;
}

struct Connection {
  oracle::occi::Environment *env;
  oracle::occi::Connection *conn;

  Connection(std::string user, std::string password, std::string db) {
    env = oracle::occi::Environment::createEnvironment(oracle::occi::Environment::DEFAULT);
    conn = env->createConnection(user, password, db);
//      conn = env->createConnection ("scott", "tiger", "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");
  }
};

std::list<Connection*> connections;

void Connect(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle username_object = HandleError(Dart_GetNativeArgument(arguments, 0));
  const char* username;
  HandleError(Dart_StringToCString(username_object, &username));
  Dart_Handle password_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  const char* password;
  HandleError(Dart_StringToCString(password_object, &password));
  Dart_Handle db_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  const char* db;
  HandleError(Dart_StringToCString(db_object, &db));

  connections.push_back(new Connection(username, password, db));
  Dart_Handle result = HandleError(Dart_NewInteger(connections.size()));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}  

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"Connect", Connect},
    {NULL, NULL}};

Dart_NativeFunction ResolveName(Dart_Handle name,
                                int argc,
                                bool* auto_setup_scope) {
  if (!Dart_IsString(name)) return NULL;
  Dart_NativeFunction result = NULL;
  if (auto_setup_scope == NULL) return NULL;
  *auto_setup_scope = true;
  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  for (int i=0; function_list[i].name != NULL; ++i) {
    if (strcmp(function_list[i].name, cname) == 0) {
      result = function_list[i].function;
      break;
    }
  }
  Dart_ExitScope();
  return result;
}
