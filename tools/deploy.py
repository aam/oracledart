#!/usr/bin/python
import optparse
import os
import subprocess
import tempfile
import platform
import sys


def Main():
    platformid = platform.system()
    if platformid == "Linux" or platformid == "Darwin":
        copycommand = "cp"
    elif platformid == "Windows" or platformid == "Microsoft":
        copycommand = "copy"
    else:
        print "Unsupported platform"
        return 1

    parser = optparse.OptionParser()
    parser.add_option("-f", "--file",
        help='Binary to push.',
        default=None)
    parser.add_option("-p", "--publishToRepo",
        help='Publish binaries to specified dist repo.',
        default=None)
    (options, args) = parser.parse_args()
    if options.file == None:
        parser.error("Binary file name to be pushed is mandatory.")
    if options.publishToRepo == None:
        parser.error("Destination repo is mandatory.")

    filename = os.path.basename(options.file)

    tempdir = tempfile.mkdtemp(prefix='oracledart_dist')
    original_workingdirectory = os.getcwd()
    os.chdir(tempdir)
    result = subprocess.call(["git", "clone", options.publishToRepo, tempdir])
    if (result != 0):
        return result
    result = subprocess.call("%s %s %s" %
                    (copycommand,
                        os.path.join(original_workingdirectory, options.file),
                     os.path.join(tempdir, "lib", filename)),
                    shell=True)
    if (result != 0):
        return result
    result = subprocess.call(["git", "add", os.path.join("lib", filename)])
    if (result != 0):
        return result
    result = subprocess.call(["git", "commit",
                     "-m", 'Automatic build binary update'])
    if (result != 0):
        return result
    result = subprocess.call(["git", "push"])
    if (result != 0):
        return result
    os.chdir(original_workingdirectory)
    os.rmdir(tempdir)

if __name__ == '__main__':
    sys.exit(Main())
