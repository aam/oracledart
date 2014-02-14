import platform
import subprocess
import os
import sys

def Main():
  platformid = platform.system()
  env = os.environ.copy()
  if not "JAVA_HOME" in env:
    print "JAVA_HOME is not set up"
    return 3
  if platformid == "Linux":
    print "linux not supported"
    return 2
  elif platformid == "Darwin":
    subprocess.call(["ln", "$ORACLE_OCCI_LIB_HOME/libocci.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libocci.dylib"])
    subprocess.call(["ln", "$ORACLE_OCCI_LIB_HOME/libclntsh.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libclntsh.dylib"])
    env["ORACLE_OCI_HOME"] = "~/Downloads/instantclient_11_2/sdk"
    env["ORACLE_OCCI_LIB_HOME"] = "~/Downloads/instantclient_11_2-2"
    args = ['xcodebuild', 
            '-project', 'oracledart.xcodeproj',
            '-configuration', 'ReleaseIA32',
            'SYMROOT=`pwd`/../dart/xcodebuild']
    extensionbinary = "../dart/xcodebuild/ReleaseIA32/liboracledart_extension.dylib"
  elif platformid == "Windows" or platformid == "Microsoft":
    args = ['devenv',
        'oracledart.sln',
        '/build',
        'ReleaseIA32'
    ]
    extensionbinary = "..\\dart\\build\\ReleaseIA32\\oracledart_extension.dll"
  else:
    print "Unsupported platform"
    return 1

  print " ".join(args)
  process = subprocess.Popen(args, stdin=None, env=env)
  process.wait()
  print "Completed with %d" % (process.returncode)
  if process.returncode == 0:
    if platformid == "Linux" or platformid == "Darwin":
        subprocess.call(
          ["cp", "../dart/xcodebuild/ReleaseIA32/liboracledart_extension.dylib", "."],
          shell=True)
    else:
        subprocess.call(
          ["copy", "..\\dart\\build\\ReleaseIA32\\oracledart_extension.dll", "."],
          shell=True)
  return process.returncode

if __name__ == '__main__':
  sys.exit(Main())
