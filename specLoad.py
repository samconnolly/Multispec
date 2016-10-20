#!/usr/bin/python
"""
specLoad.py

Automatically load all the spectra whose filenames fit a given pattern in the 
current directory. Takes one optional argument specifying the filename filter 
for the files to be loaded, otherwise uses the default filter "*grp*pha". E.g.:

  specLoad.py "*spec*pha" - load all files containing "spec" and ending in "pha"

Can also be set to load the multispec commands - see comments below.

Created on Thu Aug 20 13:44:51 2015

By Sam Connolly
"""


import os
import fnmatch
import sys

args = sys.argv

if len(args) > 1:
    nameFilter = args[1]
else:
    nameFilter = "*grp*pha"

# --- find spectra ---
spectra = os.listdir('.')
spectra = fnmatch.filter(spectra, nameFilter)

# ------ Create TCL macro -----------

# temporary file names
macrofile  = "load.tcl"

# tcl macro to run on spectra 
tclmacro = \
'puts "Starting macro..."\n'

#!!! uncomment to load multispec commands on xspec startup
#tclmacro = tclmacro + '@/data/sdc1g08/HDData/code/tclprogs/varPlot.tcl\n'

for i in range(len(spectra)):
    tclmacro = tclmacro + 'data {0}:{0} {1}\n'.format(i+1,spectra[i])

tclmacro = tclmacro + \
'ignore *:*\n\
notice *:0.5-10.0\n\
ignore bad\n\
ignore *:1 \n\
query y\n\
setplot energy \n\
cpd /xw \n\
plot ldata'

# --- Run Xspec modelling macro and save results ---

# create temporary macro file
macrofile= open(macrofile, 'w')
macrofile.write(str(tclmacro))
macrofile.close()

# run tcl script in xspec

os.system("xspec - load.tcl")
















