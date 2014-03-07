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
  args = ['python', 
          'dart/third_party/gyp/gyp_main.py',
          '--depth=oracledart',
          '-Ioracledart/tools/gyp/all.gypi',
          'oracledart/oracledart.gyp']
  sys.exit(execute(args))

if __name__ == '__main__':
  main()
