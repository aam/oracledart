# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'includes': [
    '../dart/runtime/tools/gyp/runtime-configurations.gypi',
  ],
  'targets': [
    {
      'target_name': 'oracledart_native_extension',
      'type': 'shared_library',
      'include_dirs': [
        '$(ORACLE_OCI_HOME)/include',
        '../dart/runtime'
      ],
      'sources': [
        'lib/src/oracledart_native_extension.cc',
        'lib/src/oracledart_native_extension_dllmain_win.cc',
      ],
      'defines': [
        'DART_SHARED_LIB',
      ],
      'conditions': [
        ['OS=="win"', {
          'dependencies': [
            '../dart/runtime/dart-runtime.gyp:dart', # Windows build process needs dart.lib
            '../dart/dart.gyp:create_sdk',
          ],
          'msvs_settings': {
            'VCLinkerTool': {
              'AdditionalDependencies': [ 'dart.lib', 'oci.lib', 'oraocci12.lib' ],
              'AdditionalLibraryDirectories': [ '<(PRODUCT_DIR)', '$(ORACLE_OCI_HOME)/lib/msvc/vc11', '$(ORACLE_OCI_HOME)/lib/msvc' ],
            },
          },
        }],
        ['OS=="mac"', {
          'xcode_settings': {
            'OTHER_LDFLAGS': [ '-undefined', 'dynamic_lookup', '-locci', '-lclntsh', '-L$(ORACLE_OCCI_LIB_HOME)' ],
          },
        }],
        ['OS=="linux"', {
          'cflags': [
            '-fPIC',
          ],
          'link_settings': {                                                    
            'libraries': [                                                      
              '-locci', '-lclntsh', '-L$(ORACLE_OCCI_LIB_HOME)'                 
            ]                                                                   
          }
        }],
      ],
    },
  ],
}
