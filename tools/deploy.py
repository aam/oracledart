#!/usr/bin/python
import optparse
import os
import subprocess
import tempfile
import platform
import sys
import shutil
import time

def deploy(original_workingdirectory, tempdir, options):
    os.chdir(tempdir)
    result = subprocess.call(["git", "clone", options.publishToRepo, tempdir])
    if (result != 0):
        return result

    platformid = platform.system()
    if platformid == "Linux" or platformid == "Darwin":
        subprocess.call("cp %s %s" % (options.file, os.path.join(tempdir, "lib")), shell=True)
    elif platformid == "Windows" or platformid == "Microsoft":
        f = open("package_exclusion.txt", "w")
        f.write("packages\\\n")
        f.write("packages/\n")
        f.write("lib\\src\\\n")
        f.write("lib/src/\n")
        f.close()
        subprocess.call("xcopy %s %s /s/i/y /exclude:package_exclusion.txt" %
                (os.path.join(original_workingdirectory, "lib"),
                 os.path.join(tempdir, "lib")), shell=True)
        subprocess.call("xcopy %s %s /s/i/y /exclude:package_exclusion.txt" %
                (os.path.join(original_workingdirectory, "test"),
                 os.path.join(tempdir, "test")), shell=True)
        os.remove("package_exclusion.txt")
        subprocess.call("copy %s %s" %
                (os.path.join(original_workingdirectory, "pubspec.yaml"),
                 tempdir), shell=True)
    else:
        raise "Unexpected platform %s - should have been caught earlier" % platformid
    result = subprocess.call(["git", "commit", "-a", "-m", 'Automatic build binary update'])
    print("git commit -> %d" % result)
    if (result != 0):
        return result
    result = subprocess.call(["git", "push"])
    print("git push -> %d" % result)
    if (result != 0):
        return result

def Main():
    platformid = platform.system()
    if not (platformid == "Linux" or platformid == "Darwin" or
            platformid == "Windows" or platformid == "Microsoft"):
        print "Unexpected platform %s - should have been caught earlier" % platformid
        return -1
    parser = optparse.OptionParser()
    parser.add_option("-p", "--publishToRepo",
        help='Publish binaries to specified dist repo.',
        default=None)
    parser.add_option("-f", "--file",
        help='File to publish.',
        default=None)
    (options, args) = parser.parse_args()
    if options.publishToRepo == None:
        parser.error("Destination repo is mandatory.")

    tempdir = tempfile.mkdtemp(prefix='oracledart_dist')
    original_workingdirectory = os.getcwd()
    result = deploy(original_workingdirectory, tempdir, options)
    os.chdir(original_workingdirectory)
    if platformid == "Linux" or platformid == "Darwin":
        subprocess.call(["rm", "-rf", tempdir])
    elif platformid == "Windows" or platformid == "Microsoft":
        subprocess.call(["rmdir", "/s", "/q", tempdir], shell=True)
    else:
        raise "Unexpected platform %s - should have been caught earlier" % platformid
    return result

if __name__ == '__main__':
    sys.exit(Main())
