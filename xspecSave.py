#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
xspecSave.py

Created on Wed Sep  9 14:55:02 2015

By Sam Connolly

Used to save data from xspec that xspec. Takes argument specifiers then the data
as arguments, saves these arguments to a text file. Assumes two data sets with
asymmetrical errors, as that's what xspec provides. Optional 'fname' specifier
to allow filename to be specified.

e.g.

xspecSave.py x [xvals] y [yvals] xerr1 [xerrvals1] xerr2 [xerrvals2]  \
                yerr1 [yerrvals1] yerr2 [yerrvals2] fname "filename.dat"
"""

import pylab as plt
import sys
import numpy as np
import matplotlib

#================ READ ARGUMENTS =================================================

args = sys.argv # get arguments

x = []
y = []
xe = []
ye = []
xe2 = []
ye2 = []

xdata,ydata,xerrs,yerrs,xerrs2,yerrs2,name = \
    False, False, False, False, False, False, False
fname = 'xspecParamsOut.dat' # default file name, if not specified

for arg in args:
    # check which argument we're dealing with
    if arg == 'x':
        xdata = True
        ydata,xerrs,yerrs,xerrs2,yerrs2,name = \
            False, False, False, False, False, False
    elif arg == 'y':
        ydata = True
        xdata,xerrs,yerrs,xerrs2,yerrs2,name = \
            False, False, False, False, False, False
    elif arg == 'xerr1':
        xerrs = True
        xdata,ydata,yerrs,xerrs2,yerrs2,name = \
            False, False, False, False, False, False
    elif arg == 'xerr2':
        xerrs2 = True
        xdata,ydata,yerrs,xerrs,yerrs2,name = \
            False, False, False, False, False, False
    elif arg == 'yerr1':
        yerrs = True
        xdata,xerrs,ydata,xerrs2,yerrs2,name = \
            False, False, False, False, False, False
    elif arg == 'yerr2':
        yerrs2 = True
        xdata,xerrs,ydata,xerrs2,yerrs,name = \
            False, False, False, False, False, False
    elif arg == 'fname':
        name = True
        xdata,xerrs,ydata,xerrs2,yerrs,yerrs2 = \
            False, False, False, False, False, False
    else:
        # get data from arguments
        if xdata == True:
            x = np.array(arg.split()).astype(float)
        elif ydata == True:
            y = np.array(arg.split()).astype(float)
        elif xerrs == True:
            xe = np.array(arg.split()).astype(float)
        elif yerrs == True:
            ye = np.array(arg.split()).astype(float)
        elif xerrs2 == True:
            xe2 = np.array(arg.split()).astype(float)
        elif yerrs2 == True:
            ye2 = np.array(arg.split()).astype(float)
        elif name == True:
            fname = arg

# save data to text file
np.savetxt(fname,np.array([x,xe,xe2,y,ye,ye2]).T)

