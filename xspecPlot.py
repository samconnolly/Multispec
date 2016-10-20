#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
xspecPlot.py

Created on Wed Sep  9 14:55:02 2015

By Sam Connolly

Used to plot things in xspec. Takes argument specifiers then the data
as arguments, saves these arguments to a text file. Assumes two data sets with
symmetrical errors. Model values can optionally be included for overplotting. 
If 'log' flag is included, plot will be logarithmic.
Optional 'fname' specifier to allow filename to be specified.

e.g.

xspecSave.py x [xvals] y [yvals] xe [xerrvals]  \
                ye [yerrvals] xm [xmodel] ym [ymodel] fname "filename.dat"

xspecPlot.py x $XVALS y $YVALS \
              xl $XLABEL yl $YLABEL xe $XERRS ye $YERRS xm $XMOD ym $YMOD $LOG
"""

import pylab as plt
import sys
import numpy as np
import matplotlib

#================ READ ARGUMENTS =================================================

args = sys.argv

x = []
y = []
xdata,ydata,xerr,yerr,xlabel,ylabel,xmod,ymod = False, False, False, False, False, False, False, False
xl,yl = 'x','y'
log = False
xe,ye = None,None
xm,ym = [],[]

for arg in args:
    
    if arg in ['x','y','xe','ye','xm','ym','xl','yl','log','None']:
        xdata,ydata,xerr,yerr,xlabel,ylabel,xmod,ymod = False, False, False, False, False, False, False, False

    if arg == 'x':
        xdata = True
    elif arg == 'y':
        ydata = True
    elif arg == 'xe':
        xerr = True
    elif arg == 'ye':
        yerr = True
    elif arg == 'xl':
        xlabel = True
    elif arg == 'yl':
        ylabel = True
    elif arg == 'xm':
        xmod = True
    elif arg == 'ym':
        ymod = True
    elif arg == 'log':
        log = True
    elif arg == 'None':
        log = False
    else:
        if xdata == True:
            x = np.array(arg.split()).astype(float)
        elif ydata == True:
            y = np.array(arg.split()).astype(float)
        elif xerr == True:
            xe = np.array(arg.split()).astype(float)
        elif yerr == True:
            ye = np.array(arg.split()).astype(float)
        elif xmod == True:
            xm = np.array(arg.split()).astype(float)
        elif ymod == True:
            ym = np.array(arg.split()).astype(float)
        elif xlabel == True:
            xl = arg
        elif ylabel == True:
            yl = arg

# plot
fig = plt.figure()
    
ax = fig.add_subplot(1,1,1)

font = {'family' : 'normal',
        'weight' : 'bold',
        'size'   : 22}
matplotlib.rcParams.update({'font.size': 22})
matplotlib.rc('xtick', labelsize=20) 
matplotlib.rc('ytick', labelsize=20)

matplotlib.rcParams['ps.useafm'] = True
matplotlib.rcParams['pdf.use14corefonts'] = True
matplotlib.rcParams['text.usetex'] = True

from matplotlib.ticker import ScalarFormatter

# log plot?

if log == True:
    	ax.set_yscale('log')
    	ax.set_xscale('log')

ax.xaxis.set_major_formatter(ScalarFormatter())


if len(xm) > 0:
    plt.plot(xm,ym,color='black',linewidth=1.5)

plt.errorbar(x,y,xerr=xe,yerr=ye ,\
              marker='o', color = 'red', ecolor='grey', \
               linestyle = 'none', capsize = 0) 
plt.xlabel(xl)
plt.ylabel(yl)

fig.subplots_adjust(left=0.14, right=0.98, top=0.98,hspace=0,wspace=0,bottom=0.13)

plt.show()
