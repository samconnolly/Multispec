
# Multispec

##Multispec.tcl - tools to aid simultaneous fitting of multiple spectra in xspec      
                                                                      
###Sam Connolly, October 2016                                                  



##pyplot - plot using matplotlib

 - Accepts standard plot arguments "ldata", "lcounts", "ufspec", "eufspec", 
   "eeufspec", "ratio", "residuals". The extra argument "model" can be used
   with "ufspec", "eufspec" and "eeufspec" to overplot the model in addtion
   to the data. E.g.:

       pyplot ldata            - logarithmic plot of the data
       pyplot ufspec model     - 
   
 - Accepts the following extra arguments:
       -- "param" - plots param against spec number if one param number is given
                   or against another parameter, if two are given (x then y). 
                   Also plots against count rate (0), flux (-1) and intrinsic 
                   flux (-2) if the first param number is set as shown in 
                   parenthesis. For intrinsic flux, the second param number 
                   should be the power law normalisation, the third should 
                   be the photon index and the fourth the parameter to plot
                   against flux. E.g., for a 'wabs x pow' model in which
                   param 1 is absorbing column, param 2 is photon index and
                   param 3 is power law normalisation:

        pyplot param 1        - plot spec no. (x) against absorbing column (y)
        pyplot param 3 2      - plot normalisation (x) against photon index (y)
        pyplot param 0 2      - plot count rate (x) against photon index (y)
        pyplot param -1 2     - plot spectrum flux (x) against photon index (y)
        pyplot param -2 3 2 1 - plot intrinsic power law flux (x) against 
                                absorbing column (y)
       -- "colour" - plots a colour-colour plot of the fluxes of each spectrum
                    as folded through the current model. Requires four energy
                    limit arguments. E.g. for a 0.5-2 v. 2-10 keV colour plot:

        pyplot colour 0.5 2.0 2.0 10.0

       -- "hardness" - plots the hardnesses v. fluxes of each spectrum, as
                      folded through the current model. Requires four energy
                      limit arguments. E.g. for a 0.5-2/2-10 keV hardness v.
                      0.5-2 keV flux plot:

        pyplot hardness 0.5 2.0 2.0 10.0


##multiparam - change a model parameter for all spectra simultaneously

 - Accepts a parameter number (as numbered for the first spectrum) and a value
   to which this parameter will be set for all spectra. Also allows freezing,
   thawing and linking of parameters. E.g.:

       multiparam 2 3.2    - Set parameter 2 to 3.2 for all spectra
       multiparam 2 3.2,-1 - Set parameter 2 to 3.2, frozen, for all spectra
       multiparam freeze 2 - Freeze parameter 2 for all spectra
       multiparam thaw 3.2 - Thaw parameter 2 for all spectra
       multiparam 2 =2     - Set parameter 2 equal that that of the first 
                             spectrum for all spectra

##saveparam - save the values and errors of two parameters to file

 - Requires the numbers of the two parameters to be written to a text file as 
   an argument. Also saves one parameter with count rate (0), flux (-1), 
   intrinsic count rate (-2) and intrinsic flux (-3/-4) if the first param 
   number is set as shown in parenthesis. For intrinsic count rate or flux, 
   the second param number should be the power law normalisation, the third 
   should be the photon index and the fourth the parameter to save. The 
   intrinsic flux is calculated between 0.5 and 10 keV for an argument of -3,
   or between the 3rd and 4th arguments, for a first argument of -4. 
   Optionally, a final argument giving the name of the output file can be 
   given, otherwise the default name 'xspecParamsOut.dat' is used. 
   The errors are calculated from the confidence region of each 
   parameter. E.g., for a 'wabs x pow' model in which param 1 is absorbing 
   column, param 2 is photon index and param 3 is power law normalisation:

       saveparam param 3 2              - save normalisation and photon index
       saveparam param 3 2              - save normalisation and photon index
       saveparam param 0 2              - save count rate and photon index 
       saveparam param -1 2             - save spectrum flux and photon index 
       saveparam param -2 3 2 1         - save intrinsic power law count rate 
                                          and absorbing column
       saveparam param -3 3 2 1         - save intrinsic 0.5-10.0 keV power law 
                                          flux and absorbing column
       saveparam param -4 3 2 1 2.0 7.0 - save intrinsic 2.0-7.0 keV power law 
                                          flux and absorbing column
       saveparam param 3 2 "params.dat" - save normalisation and photon index
                                          in the file "params.dat"


##extractabs - save the flux and absorption fraction of each spectrum

 - Takes a single argument giving the component number of the absorption
   component whose effect is to be extracted. The fractional change in the
   flux of each spectrum is recorded alongside its unabsorbed flux. A second
   argument can optionally be given to specify the name of the output file,
   otherwise the default name 'multiComp.dat' will be used. E.g. for the model
   'wabs x pow', so that the first component is the absorbing component:

       extractabs 1           - save the absorption fraction and flux
       extractabs 1 'abs.dat' - save the absorption fraction and flux in the 
                                file 'abs.dat'

## Python scripts used by multispec.tcl

###xspecPlot.py

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

###xspecSave.py

Used to save data from xspec that xspec. Takes argument specifiers then the data
as arguments, saves these arguments to a text file. Assumes two data sets with
asymmetrical errors, as that's what xspec provides. Optional 'fname' specifier
to allow filename to be specified.

e.g.

xspecSave.py x [xvals] y [yvals] xerr1 [xerrvals1] xerr2 [xerrvals2]  \
                yerr1 [yerrvals1] yerr2 [yerrvals2] fname "filename.dat"
