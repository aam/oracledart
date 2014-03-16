#!/usr/bin/python
import optparse
import os
import subprocess
import tempfile

parser = optparse.OptionParser()
parser.add_option("-f", "--file",
    help='Binary to push.',
    default=None)
parser.add_option("-p", "--publishToRepo",
    help='Publish binaries to specified dist repo.',
    default=None)
(options, args) = parser.parse_args()

filename = os.path.basename(options.file)

tempdir = tempfile.mkdtemp(prefix='oracledart_dist')
original_workingdirectory = os.getcwd()
os.chdir(tempdir)

subprocess.call(["git", "clone", options.publishToRepo, tempdir])
subprocess.call("cp %s %s" %
                (os.path.join(original_workingdirectory, options.file),
                 os.path.join(tempdir, "lib", filename)),
                shell=True)
subprocess.call(["git", "add", os.path.join("lib", filename)])
subprocess.call(["git", "commit",
                 "-m", '"Automatic build binary update"'])
subprocess.call(["git", "push"])

os.chdir(original_workingdirectory)

