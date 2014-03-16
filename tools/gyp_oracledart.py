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

def main():
  shutil.rmtree('oracledart/tools/gyp', ignore_errors=True)
  shutil.copytree('dart/tools/gyp',
      'oracledart/tools/gyp',
      ignore=shutil.ignore_patterns('.svn'))
  infile = open('dart/tools/gyp/configurations_msvs.gypi')
  outfile = open('oracledart/tools/gyp/configurations_msvs.gypi', 'w')
  for line in infile:
    line = line.replace("'ExceptionHandling': '0',", "'ExceptionHandling': '1',")
    outfile.write(line)
  infile.close()
  outfile.close()

  infile = open('dart/tools/gyp/configurations_make.gypi')
  outfile = open('oracledart/tools/gyp/configurations_make.gypi', 'w')
  for line in infile:
    line = line.replace("'-fno-exceptions',", "'-fexceptions',")
    outfile.write(line)
  infile.close()
  outfile.close()

  infile = open('dart/tools/gyp/configurations_xcode.gypi')
  outfile = open('oracledart/tools/gyp/configurations_xcode.gypi', 'w')
  for line in infile:
    line = line.replace("'GCC_ENABLE_CPP_EXCEPTIONS': 'NO', # -fno-exceptions", 
        "'GCC_ENABLE_CPP_EXCEPTIONS': 'YES', # -fexceptions")
    outfile.write(line)
  infile.close()
  outfile.close()

  args = ['python', 
          'dart/third_party/gyp/gyp_main.py',
          '--depth=oracledart',
          '-Ioracledart/tools/gyp/all.gypi',
          'oracledart/oracledart.gyp']
  sys.exit(execute(args))

if __name__ == '__main__':
  main()
