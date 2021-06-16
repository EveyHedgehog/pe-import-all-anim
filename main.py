import os, re, sys
from subprocess import Popen, PIPE, STDOUT, CalledProcessError

print("Starting Animation importer...")
cmd="ruby animationImport.rb"
p=Popen(cmd, shell=True, stdout=PIPE)
for line in iter(p.stdout.readline, ''):
    print (line,)
    sys.stdout.flush()
    if not line:
        break
output, errors = p.communicate()
