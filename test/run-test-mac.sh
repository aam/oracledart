#!/bin/bash
DYLD_LIBRARY_PATH=~/Downloads/instantclient_11_2-2 ../../dart/xcodebuild/ReleaseIA32/dart oracledart_async_extension_test.dart
DYLD_LIBRARY_PATH=~/Downloads/instantclient_11_2-2 ../../dart/xcodebuild/ReleaseIA32/dart oracledart_sync_extension_test.dart
