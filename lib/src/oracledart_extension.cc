// Copyright (c) 2014, Alexander Aprelev.  Please see the AUTHORS file
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

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName, NULL);
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
  }

  void Terminate() {
    env->terminateConnection(conn);
    oracle::occi::Environment::terminateEnvironment(env);
    conn = NULL;
    env = NULL;
  }
};

struct OracleStatement {
  OracleConnection *connection;
  oracle::occi::Statement *statement;

  OracleStatement(OracleConnection *connection,
                  oracle::occi::Statement *statement):
      connection(connection),
      statement(statement) {}

  void Close() {
    if (connection != NULL && connection->conn != NULL) {
      connection->conn->terminateStatement(statement);
      connection = NULL;
      statement = NULL;
    }
  }
};

struct OracleResultset {
  OracleStatement *statement;
  oracle::occi::ResultSet *resultset;

  OracleResultset(OracleStatement *statement,
                  oracle::occi::ResultSet *resultset):
      statement(statement),
      resultset(resultset) {}

  void Close() {
    if (statement != NULL
      && resultset != NULL
      && statement->statement != NULL
      && statement->connection->conn != NULL) {
      statement->statement->closeResultSet(resultset);
      statement = NULL;
      resultset = NULL;
	  }
  }
};

struct OracleMetadataVector {
  std::vector<oracle::occi::MetaData> v_metadata;

  OracleMetadataVector(std::vector<oracle::occi::MetaData> _v_metadata):v_metadata(_v_metadata) {}
};

static void OracleConnectionFinalizer(void* isolate_callback_data,
                                      Dart_WeakPersistentHandle handle,
                                      void* pvoid_oracle_connection) {
  OracleConnection* oracle_connection =
      static_cast<OracleConnection*>(pvoid_oracle_connection);
  oracle_connection->Terminate();
}

static void OracleStatementFinalizer(void* isolate_callback_data,
                                     Dart_WeakPersistentHandle handle,
                                     void* pvoid_oracle_statement) {
  OracleStatement* oracle_statement =
     static_cast<OracleStatement*>(pvoid_oracle_statement);
  oracle_statement->Close();
}

static void OracleResultsetFinalizer(void* isolate_callback_data,
                                     Dart_WeakPersistentHandle handle,
                                     void* pvoid_oracle_resultset) {
  OracleResultset* oracle_resultset =
      static_cast<OracleResultset*>(pvoid_oracle_resultset);
  oracle_resultset->Close();
}

void OracleConnection_Connect(Dart_NativeArguments arguments) {
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

  OracleConnection* connection = NULL;
  try {
   connection = new OracleConnection(username, password, db);
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  HandleError(Dart_SetNativeInstanceField(
      connection_obj,
      0,
      reinterpret_cast<intptr_t>(connection)));

  Dart_NewWeakPersistentHandle(
      connection_obj,
      connection,
      0,
      OracleConnectionFinalizer);

  Dart_ExitScope();
}

void OracleConnection_CreateStatement(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle connection_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleConnection* connection;
  HandleError(Dart_GetNativeInstanceField(
      connection_obj,
      0,
      reinterpret_cast<intptr_t*>(&connection)));

  Dart_Handle statement_obj = HandleError(Dart_GetNativeArgument(arguments, 1));

  Dart_Handle query_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  const char* query;
  HandleError(Dart_StringToCString(query_obj, &query));

  OracleStatement* oracleStatement = NULL;
  try {
    oracle::occi::Statement* stmt = connection->conn->createStatement(query);
    oracleStatement = new OracleStatement(connection, stmt);
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  HandleError(Dart_SetNativeInstanceField(
      statement_obj,
      0,
      reinterpret_cast<intptr_t>(oracleStatement)));

  Dart_NewWeakPersistentHandle(
      statement_obj,
      oracleStatement,
      0,
      OracleStatementFinalizer);

  Dart_ExitScope();
}

void OracleStatement_Execute(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle statement_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleStatement* oracleStatement;
  HandleError(Dart_GetNativeInstanceField(
      statement_obj,
      0,
      reinterpret_cast<intptr_t*>(&oracleStatement)));

  Dart_Handle resultset_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  oracle::occi::ResultSet *rset = NULL;
  try {
    rset = oracleStatement->statement->executeQuery();
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  OracleResultset* resultset = new OracleResultset(oracleStatement, rset);
  HandleError(Dart_SetNativeInstanceField(
      resultset_obj,
      0,
      reinterpret_cast<intptr_t>(resultset)));

  Dart_NewWeakPersistentHandle(
      resultset_obj,
      resultset,
      0,
      OracleResultsetFinalizer);

  Dart_ExitScope();
}

void OracleStatement_SetInt(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle statement_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleStatement* oracleStatement;
  HandleError(Dart_GetNativeInstanceField(
      statement_obj,
      0,
      reinterpret_cast<intptr_t*>(&oracleStatement)));

  Dart_Handle index_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t index;
  HandleError(Dart_IntegerToInt64(index_obj, &index));

  Dart_Handle value_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t value;
  HandleError(Dart_IntegerToInt64(value_obj, &value));

  try {
    oracleStatement->statement->setInt(index, value);
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  Dart_ExitScope();
}

void OracleStatement_SetString(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle statement_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleStatement* oracleStatement;
  HandleError(Dart_GetNativeInstanceField(
      statement_obj,
      0,
      reinterpret_cast<intptr_t*>(&oracleStatement)));

  Dart_Handle index_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t index;
  HandleError(Dart_IntegerToInt64(index_obj, &index));

  Dart_Handle value_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  const char* value;
  HandleError(Dart_StringToCString(value_obj, &value));

  try {
    oracleStatement->statement->setString(index, value);
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  Dart_ExitScope();
}

void OracleResultset_Next(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle resultset_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleResultset* resultset;
  HandleError(Dart_GetNativeInstanceField(
    resultset_obj,
    0,
    reinterpret_cast<intptr_t*>(&resultset)));

  try {
    Dart_Handle result = HandleError(Dart_NewBoolean(resultset->resultset->next()));
    Dart_SetReturnValue(arguments, result);
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString(exception.getMessage().c_str())));
  }

  Dart_ExitScope();
}

void OracleResultset_Get(Dart_NativeArguments arguments, oracle::occi::Type type) {
  Dart_EnterScope();

  Dart_Handle resultset_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleResultset* resultset;
  HandleError(Dart_GetNativeInstanceField(
    resultset_obj,
    0,
    reinterpret_cast<intptr_t*>(&resultset)));

  Dart_Handle index_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t index;
  HandleError(Dart_IntegerToInt64(index_obj, &index));

  Dart_Handle result = NULL;
  try {
    switch(type) {
      case oracle::occi::OCCIINT:
        result = HandleError(Dart_NewInteger(resultset->resultset->getInt(index)));
        break;
      case oracle::occi::OCCISTRING:
      {
        std::string s = resultset->resultset->getString(index);
        result = Dart_NewStringFromCString(s.c_str());
        break;
      }
      case oracle::occi::OCCIDOUBLE:
        result = Dart_NewDouble(resultset->resultset->getDouble(index));
        break;
      case oracle::occi::OCCIFLOAT:
        result = Dart_NewDouble(resultset->resultset->getFloat(index));
        break;
      default:
        Dart_PropagateError(Dart_NewApiError("Requested type is not supported by OracleDart."));
        break;
    }
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(
      Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString(
          exception.getMessage().c_str())));
  }
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

void OracleResultset_GetInt(Dart_NativeArguments arguments) {
  return OracleResultset_Get(arguments, oracle::occi::OCCIINT);
}

void OracleResultset_GetString(Dart_NativeArguments arguments) {
  return OracleResultset_Get(arguments, oracle::occi::OCCISTRING);
}

void OracleResultset_GetDouble(Dart_NativeArguments arguments) {
  return OracleResultset_Get(arguments, oracle::occi::OCCIDOUBLE);
}

void OracleResultset_GetFloat(Dart_NativeArguments arguments) {
  return OracleResultset_Get(arguments, oracle::occi::OCCIFLOAT);
}

void OracleResultset_GetMetadataVector(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle resultset_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleResultset* resultset;
  HandleError(Dart_GetNativeInstanceField(
    resultset_obj,
    0,
    reinterpret_cast<intptr_t*>(&resultset)));

  Dart_Handle metadata_vector_obj = HandleError(Dart_GetNativeArgument(arguments, 1));

  OracleMetadataVector* metadata_vector = NULL;
  try {
    metadata_vector = new OracleMetadataVector(
        resultset->resultset->getColumnListMetaData());
  } catch(oracle::occi::SQLException exception) {
    Dart_PropagateError(
        Dart_NewUnhandledExceptionError(
            Dart_NewStringFromCString(
                exception.getMessage().c_str())));
  }

  HandleError(Dart_SetNativeInstanceField(
      metadata_vector_obj,
      0,
      reinterpret_cast<intptr_t>(metadata_vector)));

  Dart_ExitScope();
}

void OracleMetadataVector_GetSize(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle metadata_vector_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleMetadataVector* metadata_vector;
  HandleError(Dart_GetNativeInstanceField(
    metadata_vector_obj,
    0,
    reinterpret_cast<intptr_t*>(&metadata_vector)));

  Dart_Handle result = NULL;
  result = HandleError(Dart_NewInteger(metadata_vector->v_metadata.size()));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

void OracleMetadataVector_GetColumnName(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  Dart_Handle metadata_vector_obj = HandleError(Dart_GetNativeArgument(arguments, 0));
  OracleMetadataVector* metadata_vector;
  HandleError(Dart_GetNativeInstanceField(
    metadata_vector_obj,
    0,
    reinterpret_cast<intptr_t*>(&metadata_vector)));

  Dart_Handle index_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t index;
  HandleError(Dart_IntegerToInt64(index_obj, &index));

  Dart_Handle result = HandleError(Dart_NewStringFromCString(
      std::string(metadata_vector->v_metadata.at(index).getString(oracle::occi::MetaData::ATTR_NAME)).c_str()));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"OracleConnection_Connect", OracleConnection_Connect},
    {"OracleConnection_CreateStatement", OracleConnection_CreateStatement},
    {"OracleStatement_Execute", OracleStatement_Execute},
    {"OracleStatement_SetInt", OracleStatement_SetInt},
    {"OracleStatement_SetString", OracleStatement_SetString},
    {"OracleResultset_GetString", OracleResultset_GetString},
    {"OracleResultset_GetInt", OracleResultset_GetInt},
    {"OracleResultset_GetDouble", OracleResultset_GetDouble},
    {"OracleResultset_GetFloat", OracleResultset_GetFloat},
    {"OracleResultset_Next", OracleResultset_Next},
    {"OracleResultset_GetMetadataVector", OracleResultset_GetMetadataVector},
    {"OracleMetadataVector_GetSize", OracleMetadataVector_GetSize},
    {"OracleMetadataVector_GetColumnName", OracleMetadataVector_GetColumnName},

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
