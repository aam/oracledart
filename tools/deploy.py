#!/usr/bin/python
import optparse
import os
import subprocess
import tempfile
import platform
import sys
import shutil
import time

def deploy(copycommand, original_workingdirectory, tempdir, filename, options):
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
    print("git add -> %d" % result)
    if (result != 0):
        return result
    result = subprocess.call(["git", "commit",
                     "-m", 'Automatic build binary update'])
    print("git commit -> %d" % result)
    if (result != 0):
        return result
    result = subprocess.call(["git", "push"])
    print("git push -> %d" % result)
    if (result != 0):
        return result

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
    result = deploy(copycommand, original_workingdirectory, tempdir, filename, options)
    os.chdir(original_workingdirectory)
    print("Now in %s" % os.getcwd())
    cnt = 0
    while cnt < 5:
        try:
            if platformid == "Linux" or platformid == "Darwin":
                subprocess.call(["rm", "-rf", tempdir])
            elif platformid == "Windows" or platformid == "Microsoft":
                subprocess.call(["rmdir", "/s", "/q", tempdir], shell=True)
            else:
                raise "Unexpeced platform - should have been caught earlier"
            print("Removed %s" % (tempdir))
            break
        except:
            print "Failed to delete %s. Sleeping..." % (tempdir)
            cnt += 1
        time.sleep(5)
    return result

if __name__ == '__main__':
    sys.exit(Main())
