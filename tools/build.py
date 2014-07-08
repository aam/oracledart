#!/usr/bin/python

import platform
import subprocess
import os
import sys
import optparse


def Main():

    parser = optparse.OptionParser()
    parser.add_option("-p", "--publishToRepo",
                      help='Publish binaries to specified dist repo.',
                      default=None)
    parser.add_option("-a", "--architecture",
                      help='Publish binaries to specified dist repo.',
                      default='ia32')
    (options, args) = parser.parse_args()

    userhome = os.path.expanduser("~")
    platformid = platform.system()
    env = os.environ.copy()

    targetExtensionLibrary = None

    if platformid == "Linux":
        env["ORACLE_OCI_HOME"] = (
            "%s/Downloads/instantclient_11_2/sdk" % userhome)
        env["ORACLE_OCCI_LIB_HOME"] = (
            "%s/Downloads/instantclient_11_2" % userhome)
        buildCommand = ['make', '-j', '8', 'BUILDTYPE=ReleaseIA32']
        extensionlibrary = (
            "out/ReleaseIA32/lib.target/liboracledart_extension.so")

    elif platformid == "Darwin":
        ORACLE_OCCI_LIB_HOME = "%s/Downloads/instantclient_11_2-2" % userhome
        subprocess.call(
            ["ln",
             "%s/libocci.dylib.11.1" % ORACLE_OCCI_LIB_HOME,
             "%s/libocci.dylib" % ORACLE_OCCI_LIB_HOME])
        subprocess.call(
            ["ln",
             "%s/ORACLE_OCCI_LIB_HOME/libclntsh.dylib.11.1" %
                ORACLE_OCCI_LIB_HOME,
             "%s/libclntsh.dylib" % ORACLE_OCCI_LIB_HOME])
        env["ORACLE_OCI_HOME"] = ("%s/Downloads/instantclient_11_2/sdk" %
                                  userhome)
        env["ORACLE_OCCI_LIB_HOME"] = ORACLE_OCCI_LIB_HOME
        buildCommand = ['xcodebuild',
                        '-project', 'oracledart.xcodeproj',
                        '-configuration', 'ReleaseIA32',
                        'SYMROOT=%s/../dart/xcodebuild' % os.getcwd()]
        extensionlibrary = (
            "../dart/xcodebuild/ReleaseIA32/liboracledart_extension.dylib")

    elif platformid == "Windows" or platformid == "Microsoft":
        if "JAVA_HOME" not in env:
            print("JAVA_HOME is not set up")
            return 3
        os.system("mklink /J third_party ..\\dart\\third_party")
        buildConfiguration = ""
        if options.architecture == 'ia32':
            env["ORACLE_OCI_HOME"] = (
                "%s\\downloads\\"
                "instantclient-sdk-nt-12.1.0.1.0\\instantclient_12_1\\sdk" %
                userhome)
            buildConfiguration = 'ReleaseIA32|Win32'
        elif options.architecture == 'x64':
            env["ORACLE_OCI_HOME"] = (
                "%s\\downloads\\"
                "instantclient-sdk-windows.x64-12.1.0.1.0\\"
                "instantclient_12_1\\sdk" %
                userhome)
            buildConfiguration = 'ReleaseX64|x64'
        else:
            print("Invalid architecture specified %s" % (options.architecture))
            return 4

        buildCommand = ['devenv.com',
                        'oracledart.sln',
                        '/build',
                        buildConfiguration]
        extensionlibrary = (
            "build\\%s\\oracledart_extension.dll" % (
                "ReleaseX64" if options.architecture == 'x64'
                else 'ReleaseIA32'))
        if options.architecture == 'x64':
            targetExtensionLibrary = "oracledart_extension_x64.dll"
    else:
        print("Unsupported platform")
        return 1

    if targetExtensionLibrary is None:
        targetExtensionLibrary = ""

    print(" ".join(buildCommand))
    process = subprocess.Popen(buildCommand, stdin=None, env=env)
    process.wait()
    print("Completed with %d" % (process.returncode))
    if process.returncode == 0:
        if platformid == "Linux" or platformid == "Darwin":
            subprocess.call(
                "cp %s lib/%s" % (extensionlibrary, targetExtensionLibrary),
                shell=True)
        else:
            subprocess.call(
                ["copy", extensionlibrary,
                 "lib\\%s" % (targetExtensionLibrary)],
                shell=True)
        if (options.publishToRepo is not None):
            subprocess.call(
                ["python", "./tools/deploy.py",
                 "-p", options.publishToRepo,
                 "-f", extensionlibrary])
    return process.returncode

if __name__ == '__main__':
    sys.exit(Main())
