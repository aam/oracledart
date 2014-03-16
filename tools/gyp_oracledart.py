#!/usr/bin/env python

"""
Invoke gyp to generate build files for building OracleDart.
"""

import os
import subprocess
import sys
import shutil

def execute(args):
  process = subprocess.Popen(args)
  process.wait()
  return process.returncode

def replace_in_config_file(filename_suffix, replacements):
  infile = open('dart/tools/gyp/configurations_%s.gypi' % filename_suffix)
  outfile = open('oracledart/tools/gyp/configurations_%s.gypi' % filename_suffix, 'w')
  for line in infile:
    for source, target in replacements.iteritems():
      line = line.replace(source, target)
    outfile.write(line)
  infile.close()
  outfile.close()


def main():
  shutil.rmtree('oracledart/tools/gyp', ignore_errors=True)
  shutil.copytree('dart/tools/gyp',
      'oracledart/tools/gyp',
      ignore=shutil.ignore_patterns('.svn'))

  replace_in_config_file('msvs', 
      {"'ExceptionHandling': '0',": "'ExceptionHandling': '1',"})
  replace_in_config_file('make', 
      {"'-fno-exceptions',": "'-fexceptions',"})
  replace_in_config_file('xcode', 
      {"'GCC_ENABLE_CPP_EXCEPTIONS': 'NO', # -fno-exceptions":
          "'GCC_ENABLE_CPP_EXCEPTIONS': 'YES', # -fexceptions",
       "'GCC_ENABLE_CPP_RTTI': 'NO', # -fno-rtti":
          "'GCC_ENABLE_CPP_RTTI': 'YES', # -frtti"})

  args = ['python', 
          'dart/third_party/gyp/gyp_main.py',
          '--depth=oracledart',
          '-Ioracledart/tools/gyp/all.gypi',
          'oracledart/oracledart.gyp']
  sys.exit(execute(args))

if __name__ == '__main__':
  main()
