// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>

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

struct OracleConnection {
  oracle::occi::Environment *env;
  oracle::occi::Connection *conn;

  OracleConnection(std::string user, std::string password, std::string db) {
    env = oracle::occi::Environment::createEnvironment(oracle::occi::Environment::DEFAULT);
    conn = env->createConnection(user, password, db);
//      conn = env->createConnection ("scott", "tiger", "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))");
  }

  void Terminate() {
    env->terminateConnection(conn);
    oracle::occi::Environment::terminateEnvironment(env);
    std::cout << "Closed connection" << std::endl;
  }
};

static void OracleConnectionFinalizer(Dart_WeakPersistentHandle handle,
  void* pvoid_oracle_connection) {
  Dart_DeleteWeakPersistentHandle(handle);
  OracleConnection* oracle_connection = 
    static_cast<OracleConnection*>(pvoid_oracle_connection);
  oracle_connection->Terminate();
}

void Connect(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle connection_obj = Dart_GetNativeArgument(arguments, 0);

  Dart_Handle username_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  const char* username;
  HandleError(Dart_StringToCString(username_object, &username));
  Dart_Handle password_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  const char* password;
  HandleError(Dart_StringToCString(password_object, &password));
  Dart_Handle db_object = HandleError(Dart_GetNativeArgument(arguments, 3));
  const char* db;
  HandleError(Dart_StringToCString(db_object, &db));

  OracleConnection* connection = new OracleConnection(username, password, db);
  HandleError(Dart_SetNativeInstanceField(
      connection_obj,
      0,
      reinterpret_cast<intptr_t>(connection)));

  Dart_NewWeakPersistentHandle(
      connection_obj,
      connection,
      OracleConnectionFinalizer);

  Dart_Handle result = HandleError(Dart_NewInteger(0));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

void Select(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle connection_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleConnection* connection;
  HandleError(Dart_GetNativeInstanceField(
      connection_obj,
      0,
      reinterpret_cast<intptr_t*>(&connection)));
  
  Dart_Handle query_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  const char* query;
  HandleError(Dart_StringToCString(query_object, &query));

  oracle::occi::Statement* stmt = connection->conn->createStatement (query);
  oracle::occi::ResultSet *rset = stmt->executeQuery();
  while (rset->next ()) {
    std::cout << "author_id: " << rset->getInt (1) << "  author_name: " 
              << rset->getString (2) << std::endl;
  }

  stmt->closeResultSet (rset);
  connection->conn->terminateStatement (stmt);

  Dart_Handle result = HandleError(Dart_NewInteger(0));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"Connect", Connect},
    {"Select", Select},
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
