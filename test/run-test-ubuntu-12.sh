#!/bin/bash
cp packages/oracledart/src/liboracledart_native_extension.so packages/oracledart/src/liboracledart_native_extension_bk.so
cp packages/oracledart/src/liboracledart_native_extension_12_1.so packages/oracledart/src/liboracledart_native_extension.so
LD_LIBRARY_PATH=~/Downloads/instantclient_12_1 ../../dart/out/ReleaseIA32/dart --checked oracledart_test.dart
rc=$?
cp packages/oracledart/src/liboracledart_native_extension_bk.so packages/oracledart/src/liboracledart_native_extension.so
rm packages/oracledart/src/liboracledart_native_extension_bk.so
exit $rc
