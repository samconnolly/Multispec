################################################################################
#                                                                              #
#  Multispec.tcl - tools to aid simultaneous fitting of multiple spectra       #
#                  in xspec                                                    #
#                                                                              #
#  Sam Connolly, October 2016                                                  #
#                                                                              #
################################################################################

# Python file locations
set PYSCRIPT_ROUTE /route/to/scripts

# pyplot - plot using matplotlib
#
# - Accepts standard plot arguments "ldata", "lcounts", "ufspec", "eufspec", 
#   "eeufspec", "ratio", "residuals". The extra argument "model" can be used
#   with "ufspec", "eufspec" and "eeufspec" to overplot the model in addtion
#   to the data. E.g.:
#
#       pyplot ldata 1         - logarithmic plot of the data
#       pyplot ufspec model 1  - plot of the folded spectrum and fitted model 
#                                of spectrum 1
#   
# - Accepts the following extra arguments:
#       ~ "param" - plots param against spec number if one param number is given
#                   or against another parameter, if two are given (x then y). 
#                   Also plots against count rate (0), flux (-1) and intrinsic 
#                   flux (-2) if the first param number is set as shown in 
#                   parenthesis. For intrinsic flux, the second param number 
#                   should be the power law normalisation, the third should 
#                   be the photon index and the fourth the parameter to plot
#                   against flux. E.g., for a 'wabs x pow' model in which
#                   param 1 is absorbing column, param 2 is photon index and
#                   param 3 is power law normalisation:
#
#        pyplot param 1        - plot spec no. (x) against absorbing column (y)
#        pyplot param 3 2      - plot normalisation (x) against photon index (y)
#        pyplot param 0 2      - plot count rate (x) against photon index (y)
#        pyplot param -1 2     - plot spectrum flux (x) against photon index (y)
#        pyplot param -2 3 2 1 - plot intrinsic power law flux (x) against 
#                                absorbing column (y)
#       ~ "colour" - plots a colour-colour plot of the fluxes of each spectrum
#                    as folded through the current model. Requires four energy
#                    limit arguments. E.g. for a 0.5-2 v. 2-10 keV colour plot:
#
#        pyplot colour 0.5 2.0 2.0 10.0
#
#       ~ "hardness" - plots the hardnesses v. fluxes of each spectrum, as
#                      folded through the current model. Requires four energy
#                      limit arguments. E.g. for a 0.5-2/2-10 keV hardness v.
#                      0.5-2 keV flux plot:
#
#        pyplot hardness 0.5 2.0 2.0 10.0
#
proc pyplot {arg0 {arg1 1} {arg2 none} {arg3 none} {arg4 none}} {

set LOG None
set FLUX False
set INTFLUX False
set SPECNUM False

if {$arg3 == "bin"} {

    }

    # parameter plot
    if {$arg0 == "param"} {

        if {$arg2 == "none"} {
            echo "Plotting parameter $arg1 v. spec no."
        } else {
            if {$arg1 > 0} {
                echo "Plotting parameter $arg1 v. $arg2"
            } elseif {$arg1 == 0} {
		        echo "Plotting rate v. parameter $arg2"
	        } elseif {$arg1 == -1} {
                echo "Plotting flux v. parameter $arg2"
            } elseif {$arg1 == -2} {
                echo "Plotting intrinsic flux v. parameter $arg2"
            }
        }

        # get number of spectra, model params
        tclout datasets
        set N $xspec_tclout
        tclout modpar
        set TP $xspec_tclout
        set P [expr $TP / $N ]

        # get param names
        if {$arg1 > 0} {
	        tclout pinfo $arg1
	        set XLABEL $xspec_tclout
	    } elseif {$arg1 == 0} {
		    set XLABEL "Count Rate"
	    } elseif {$arg1 == -1} {
		    set XLABEL "Flux"
		    set FLUX True
	    } elseif {$arg1 == -2} {
		    set XLABEL "Intrinsic Flux"
		    set INTFLUX True
	    }

        if {$arg2 == "none"} {
	        tclout pinfo $arg1
	        set YLABEL $xspec_tclout
            set SPECNUM True
        } elseif {$arg1 == -2} {
		    set YLABEL "Photon Index"
		    set INTFLUX True
	    } elseif {$arg2 > 0} {
	        tclout pinfo $arg2
	        set YLABEL $xspec_tclout
	    } elseif {$arg2 == 0} {
		    set YLABEL "Count Rate"
	    } elseif {$arg2 == -1} {
		    set YLABEL "Flux"
		    set INTFLUX True
	    }

	    # calculate fluxes if necessary
	    if {$FLUX == True} {
		    flux 0.5 10.0 err 1000 90		
	    }

        # get param values
        set XVALS ""
        set YVALS ""

        set i 0
        while { $i < $N } {

            if {$SPECNUM == False} {
            	if {$arg1 > 0} {
	                tclout par [expr $arg1 + $P*$i]
	                set XVAL [lindex $xspec_tclout 0]
	            } elseif {$arg1 == 0} {
	            	tclout rate [expr $i + 1]
	            	set XVAL [lindex $xspec_tclout 0]
	            } elseif {$arg1 == -1} {
	            	tclout flux [expr $i + 1]
	            	set XVAL [lindex $xspec_tclout 0]
	            } elseif {$arg1 == -2} {
	            	tclout par [expr $arg2 + $P*$i]
	            	set NORM [lindex $xspec_tclout 0]
	            	tclout par [expr $arg3 + $P*$i]
	            	set PHOT [lindex $xspec_tclout 0]
	            	set XVAL [expr $NORM*(10.0**(1-$PHOT) \
                                - 0.5**(1-$PHOT))/(1-$PHOT)]
	            }
            } else {
                set XVAL [expr $i + 1]
            }

            append XVALS " " $XVAL          

            if {$SPECNUM == False} {
                if {$arg1 == -2} {
                	#set YVAL $PHOT
	                tclout par [expr $arg4 + $P*$i]
	                set YVAL [lindex $xspec_tclout 0]
                } elseif {$arg2 > 0} {
	                tclout par [expr $arg2 + $P*$i]
	                set YVAL [lindex $xspec_tclout 0]
            	} elseif {$arg2 == 0} {
	            	tclout rate [expr $i + 1]
	            	set YVAL [lindex $xspec_tclout 0]
	            } elseif {$arg2 == -1} {
	            	tclout flux [expr $i + 1]
	            	set YVAL [lindex $xspec_tclout 0]
	            }
            } else {
                tclout par [expr $arg1 + $P*$i]
                set YVAL [lindex $xspec_tclout 0]             
            }

            append YVALS " " $YVAL
            incr i
        }
    }

    # colour-colour plot
    if {$arg0 == "colour"} {
        echo "Plotting $arg1 - $arg2 v. $arg3 - $arg4"

        # get number of spectra, model params
        tclout datasets
        set N $xspec_tclout
       
        set XLABEL "$arg1 - $arg2 keV"
        set YLABEL "$arg3 - $arg4 keV"
	
	    # calculate fluxes
	
	    set XVALS ""
        set YVALS ""

	    # soft
	    flux $arg1 $arg2 err 1000 90		
	
        set i 1
        while { $i <= $N } {
        	tclout flux $i
		    set YVAL [lindex $xspec_tclout 0]	
            append YVALS " " $YVAL
        	incr i
        }

        # hard    
	    flux $arg3 $arg4 err 1000 90		
	
        set i 1
        while { $i <= $N } {
        	tclout flux $i
		    set XVAL [lindex $xspec_tclout 0]	
            append XVALS " " $XVAL
        	incr i
        }
    }

    # hardness plot
    if {$arg0 == "hardness"} {
        echo "Plotting $arg1 - $arg2 v. $arg3 - $arg4 hardness"

        # get number of spectra, model params
        tclout datasets
        set N $xspec_tclout
       
        set XLABEL "$arg3 - $arg4 keV"
        set YLABEL "Hardness"
	
	    # calculate fluxes
	
	    set XVALS ""
        set YVALS ""

	    # hard
	    flux $arg3 $arg4 
	    #err 1000 90		
	
        set i 1
        while { $i <= $N } {
        	tclout flux $i
		    set XVAL [lindex $xspec_tclout 3]	
            append XVALS " " $XVAL
        	incr i
        }

        # hardness    
	    flux $arg1 $arg2 
	    #err 1000 90		
	
        set i 1
        while { $i <= $N } {
        	tclout flux $i
		    set YVAL [lindex $xspec_tclout 3]	
		    set XVAL [lindex $XVALS [expr $i -1 ]] 
		    set YVAL [expr ($XVAL - $YVAL)/($XVAL + $YVAL)]
            append YVALS " " $YVAL
        	incr i
        }
    }

    # generic plot command
    if {$arg0 == "ldata"| $arg0 == "lcounts"| $arg0 == "ufspec"| \
        $arg0 == "eufspec"| $arg0 == "eeufspec" | $arg0 == "ratio" | \
        $arg0 == "residuals"} {

        echo "Plotting $arg0 $arg1"
        tclout plot $arg0 x $arg1
        set XVALS $xspec_tclout
        tclout plot ldata y $arg1
        set YVALS $xspec_tclout
        tclout plot ldata xerr $arg1
        set XERRS $xspec_tclout
        tclout plot ldata yerr $arg1
        set YERRS $xspec_tclout
        set XLABEL Energy
        set YLABEL Flux

        if {$arg0 == "ldata" | $arg0 == "lcounts" | $arg0 == "ufspec" | \
            $arg0 == "eufspec" | $arg0 == "eeufspec"} {
            set LOG log
        }

        if {($arg0 == "ufspec" | $arg0 == "eufspec" | $arg0 == "eeufspec") && \
             $arg2 == "model"} {

            if {$arg0 == "ufspec"} {
                set MODEL "model"
            } elseif {$arg0 == "eufspec"} {
                set MODEL "emodel"
            } elseif {$arg0 == "eeufspec"} {
                set MODEL "eemodel"
            } 

            tclout plot $MODEL x $arg1
            set XMOD $xspec_tclout
            tclout plot $MODEL y $arg1
            set YMOD $xspec_tclout
        }
    }

    global PYSCRIPT_ROUTE # Take this variable from the global namespace

    if {$arg0 == "param" | $arg0 == "colour"| $arg0 == "hardness"} {
        # plot with pyplot
        exec $PYSCRIPT_ROUTE/xspecPlot.py \
                x $XVALS y $YVALS xl $XLABEL yl $YLABEL $LOG &
    } elseif {$arg0 == "ldata"| $arg0 == "lcounts"| $arg0 == "ufspec"|\
              $arg0 == "eufspec"| $arg0 == "eeufspec" | $arg0 == "ratio" | \
              $arg0 == "residuals"} {
        if {$arg2 == "model"} {
            exec $PYSCRIPT_ROUTE/xspecPlot.py x $XVALS y $YVALS \
              xl $XLABEL yl $YLABEL xe $XERRS ye $YERRS xm $XMOD ym $YMOD $LOG &
        } else {
            exec $PYSCRIPT_ROUTE/xspecPlot.py x $XVALS y $YVALS \
                    xl $XLABEL yl $YLABEL xe $XERRS ye $YERRS $LOG &
        }
    } else {
        echo "Unknown plotting choice: use param, colour, hardness, ldata, \
lcounts, ufspec, eufspec, eeufspec, ratio or residuals"
    }

}

# multiparam - change a model parameter for all spectra simultaneously
#
# - Accepts a parameter number (as numbered for the first spectrum) and a value
#   to which this parameter will be set for all spectra. Also allows freezing,
#   thawing and linking of parameters. E.g.:
#
#       multiparam 2 3.2    - Set parameter 2 to 3.2 for all spectra
#       multiparam 2 3.2,-1 - Set parameter 2 to 3.2, frozen, for all spectra
#       multiparam freeze 2 - Freeze parameter 2 for all spectra
#       multiparam thaw 3.2 - Thaw parameter 2 for all spectra
#       multiparam 2 =2     - Set parameter 2 equal that that of the first 
#                             spectrum for all spectra
#
proc multiparam {arg0 arg1} {

    set ADD "None"
    set SUB "None"

	if {$arg0 == "freeze"} {
		echo "freezing parameter $arg1"
	} elseif {$arg0 == "thaw"} {
		echo "thawing parameter $arg1"
	} elseif {[lindex [split $arg1 {}] 0] == "+"} {
        set ADD [lindex [split $arg1 {}] 1]
		echo "Setting parameter $arg0 to $arg0 +$ADD"
	} elseif {[lindex [split $arg1 {}] 0] == "-"} {
        set SUB [lindex [split $arg1 {}] 1]
		echo "Setting parameter $arg0 to $arg0 -$SUB"
	} else {
    	echo "Setting parameter $arg0 to $arg1"
    }

    # get number of spectra, model params
    tclout datasets
    set N $xspec_tclout
    tclout modpar
    set TP $xspec_tclout
    set P [expr $TP / $N ]
   
    # set all to given value
    set i 0
    while { $i < $N } {
    	if {$arg0 == "freeze"} {
			freeze [expr $arg1 + $P*$i]
		} elseif {$arg0 == "thaw"} {
			thaw [expr $arg1 + $P*$i]
		} elseif {$ADD != "None"} {
            newpar [expr $arg0 + $P*$i]  =[expr $arg0 + $P*$i + $ADD] 
		} elseif {$SUB != "None"} {
            newpar [expr $arg0 + $P*$i]  =[expr $arg0 + $P*$i - $SUB]
		} elseif {[lindex [split $arg1 {}] 0] != "=" | $i > 0 } {
	    	newpar [expr $arg0 + $P*$i]  $arg1 
	    }
	       
        incr i
    }
}

# avflux - calculate average flux over all spectra
#
# - Requires no arguments, calculates and returns the mean flux, folded through 
#   the current model, of all spectra.
#
proc avflux {} {

    # calculate fluxes 
    flux 0.5 10.0 err 1000 90		
    
    # get number of spectra
    tclout datasets
    set N $xspec_tclout
    set TOTFLUX 0
    set i 0

    while { $i < $N } {
    	tclout flux [expr $i + 1]
    	set FLUX [lindex $xspec_tclout 0]
        set TOTFLUX [expr $TOTFLUX + $FLUX]
        incr i
    }
    echo [expr $TOTFLUX / $N]
}

# printparam - print the values of a parameter for all spectra
#
# - Requires the number of the parameter to be printed as an argument. Also
#   optionally takes the flag '-e' to include parameters' errors, as taken
#   from the covariance matrix, or '-E' to calculate and include the errors
#   calculated from the model parameters' confidence regions. E.g.
#
#       printparam 3    - Print the values of parameter 3 for all spectra
#       printparam 3 -e - Print the values and errors calculated from the fit 
#                         covariance matrix of parameter 3 for all spectra
#       printparam 3 -E - Print the values and errors calculated from the  
#                         confidence ration of parameter 3 for all spectra
#
proc printparam {{arg0 1} {arg1 none}} {
   # get number of spectra, model params
    tclout datasets
    set N $xspec_tclout
    tclout modpar
    set TP $xspec_tclout
    set P [expr $TP / $N ]

    set i 0
    set ERR ""
    while { $i < $N } {

	    if {$arg0 > 0} {
            tclout par [expr $arg0 + $P*$i]
            set VAL [lindex $xspec_tclout 0]

            if {$arg1 == "-e"} {
                tclout sigma [expr $arg0 + $P*$i]
                set ERR $xspec_tclout
            } elseif {$arg1 == "-E"} {
                error [expr $arg0 + $P*$i]
                tclout err [expr $arg0 + $P*$i]
                set ERR1 [lindex $xspec_tclout 0]
                set ERR2 [lindex $xspec_tclout 1]
                set ERR "$ERR1 $ERR2"
            } else {
                set ERR ""
            }

            echo $VAL  $ERR
        }

        incr i
    }
}

# saveparam - save the values and errors of two parameters to file
#
# - Requires the numbers of the two parameters to be written to a text file as 
#   an argument. Also saves one parameter with count rate (0), flux (-1), 
#   intrinsic count rate (-2) and intrinsic flux (-3/-4) if the first param 
#   number is set as shown in parenthesis. For intrinsic count rate or flux, 
#   the second param number should be the power law normalisation, the third 
#   should be the photon index and the fourth the parameter to save. The 
#   intrinsic flux is calculated between 0.5 and 10 keV for an argument of -3,
#   or between the 3rd and 4th arguments, for a first argument of -4. 
#   Optionally, a final argument giving the name of the output file can be 
#   given, otherwise the default name 'xspecParamsOut.dat' is used. 
#   The errors are calculated from the confidence region of each 
#   parameter. E.g., for a 'wabs x pow' model in which param 1 is absorbing 
#   column, param 2 is photon index and param 3 is power law normalisation:
#
#       saveparam param 3 2              - save normalisation and photon index
#       saveparam param 3 2              - save normalisation and photon index
#       saveparam param 0 2              - save count rate and photon index 
#       saveparam param -1 2             - save spectrum flux and photon index 
#       saveparam param -2 3 2 1         - save intrinsic power law count rate 
#                                          and absorbing column
#       saveparam param -3 3 2 1         - save intrinsic 0.5-10.0 keV power law 
#                                          flux and absorbing column
#       saveparam param -4 3 2 1 2.0 7.0 - save intrinsic 2.0-7.0 keV power law 
#                                          flux and absorbing column
#       saveparam param 3 2 "params.dat" - save normalisation and photon index
#                                          in the file "params.dat"
#
proc saveparam {{arg0 1} {arg1 2} {arg2 none} {arg3 none} {arg4 none} {arg5 none} {arg6 none}} {

    set FLUX False
    set INTFLUX False

    # parameter plot

    if {$arg1 > 0} {
        echo "Saving parameters $arg0 and $arg1"
    } elseif {$arg1 == 0} {
	    echo "Saving rate and parameter $arg1"
    } elseif {$arg1 == -1} {
        echo "Saving flux and parameter $arg1"
    } elseif {$arg1 == -2} {
        echo "Saving intrinsic flux and parameter $arg1"
    }

    # get number of spectra, model params
    tclout datasets
    set N $xspec_tclout
    tclout modpar
    set TP $xspec_tclout
    set P [expr $TP / $N ]

    # get param names
    if {$arg0 > 0} {
        tclout pinfo $arg1
        set XLABEL $xspec_tclout
    } elseif {$arg0 == 0} {
	    set XLABEL "Count Rate"
    } elseif {$arg0 == -1} {
	    set XLABEL "Flux"
	    set FLUX True
    } elseif {$arg0 == -2} {
	    set XLABEL "Intrinsic Rate"
	    set INTFLUX True
    } elseif {$arg0 == -3 | $arg0 == -4 } {
	    set XLABEL "Intrinsic Flux"
	    set INTFLUX True
        set KEV 1.602176565e-9
    }

    if {$arg2 != none && $arg0 >= -1} {
        set FNAME $arg2
    } elseif {$arg4 != none && ($arg0 == -2 | $arg0 == -3)} {
        set FNAME $arg4
    } elseif {$arg6 != none && $arg0 == -4} {
        set FNAME $arg6
    }  else {
        set FNAME "xspecParamsOut.dat"
    }

    if {$arg0 == -2 | $arg0 == -3 | $arg0 == -4 } {
        tclout pinfo $arg1
        set XLABEL $xspec_tclout
	    #set YLABEL "Photon Index"
	    set INTFLUX True
    } elseif {$arg1 > 0} {
        tclout pinfo $arg1
        set YLABEL $xspec_tclout
    } elseif {$arg1 == 0} {
	    set YLABEL "Count Rate"
    } elseif {$arg1 == -1} {
	    set YLABEL "Flux"
	    set INTFLUX True
    }

    # calculate fluxes if necessary
    if {$FLUX == True} {
	    flux 0.5 10.0 err 1000 90		
    }

    # get param values
    set XVALS ""
    set YVALS ""
    set XERRS1 ""
    set YERRS1 ""
    set XERRS2 ""
    set YERRS2 ""

    set i 0
    while { $i < $N } {

	    if {$arg0 > 0} {
            tclout par [expr $arg0 + $P*$i]
            set XVAL [lindex $xspec_tclout 0]
            err [expr $arg0 + $P*$i]
            tclout err [expr $arg0 + $P*$i]
            set XERR1 [ expr $XVAL - [lindex $xspec_tclout 0] ]
            set XERR2 [ expr [lindex $xspec_tclout 1] - $XVAL ]
        } elseif {$arg0 == 0} {
        	tclout rate [expr $i + 1]
        	set XVAL [lindex $xspec_tclout 0]
        	set XERR1 [lindex $xspec_tclout 1]
            set XERR2 $XERR1
        } elseif {$arg0 == -1} {
        	tclout flux [expr $i + 1]
        	set XVAL [lindex $xspec_tclout 0]
        	set XERR [lindex $xspec_tclout 1]
            set XERR2 $XERR1
        } elseif {$arg0 == -2} {
        	tclout par [expr $arg1 + $P*$i]
        	set NORM [lindex $xspec_tclout 0]
        	tclout par [expr $arg2 + $P*$i]
        	set PHOT [lindex $xspec_tclout 0]
        	set XVAL [expr $NORM*(10.0**(1-$PHOT) - 0.5**(1-$PHOT))/(1-$PHOT)]
            err [expr $arg1 + $P*$i]
            tclout err [expr $arg1 + $P*$i]
            set NORMERR1 [ expr $NORM - [lindex $xspec_tclout 0] ]
            set NORMERR2 [ expr [lindex $xspec_tclout 1] - $NORM ]
            err [expr $arg2 + $P*$i]
            tclout err [expr $arg2 + $P*$i]
            set PHOTERR1 [ expr $PHOT - [lindex $xspec_tclout 0] ]
            set PHOTERR2 [ expr [lindex $xspec_tclout 1] - $PHOT ]
            set NORMDIV1 [expr $NORMERR1 * \
                                  (10**(1-$PHOT) - 0.5**(1-$PHOT)) / (1-$PHOT) ]
            set NORMDIV2 [expr $NORMERR2 * \
                                  (10**(1-$PHOT) - 0.5**(1-$PHOT)) / (1-$PHOT) ]
            set PHOTDIV1 [expr $PHOTERR1*$NORM *(((log(2) * $PHOT - log(2) - 1)\
                            * 2**$PHOT * 10**$PHOT + 20 * log(10) *$PHOT - 20* \
                             log(10) + 20) / (2 * ($PHOT-1)**2.0 * 10**$PHOT) )]
            set PHOTDIV2 [expr $PHOTERR2*$NORM *(((log(2) * $PHOT - log(2) - 1)\
                            * 2**$PHOT * 10**$PHOT + 20 * log(10) \
                            *$PHOT - 20* log(10) + 20) / \
                            (2 * ($PHOT-1)**2.0 * 10**$PHOT) )]
            set XERR1 [expr sqrt( $NORMDIV1**2.0 + $PHOTDIV1**2.0 ) ]
            set XERR2 [expr sqrt( $NORMDIV2**2.0 + $PHOTDIV2**2.0 ) ]
        } elseif {$arg0 == -3} {
                
        	tclout par [expr $arg1 + $P*$i]
        	set NORM [lindex $xspec_tclout 0]
            puts $arg2
        	tclout par [expr $arg2 + $P*$i]
        	set PHOT [lindex $xspec_tclout 0]
            
        	set XVAL [expr ($NORM*(10.0**(2-$PHOT) - 0.5**(2-$PHOT))/\
                                                            (2-$PHOT))* $KEV]
            err [expr $arg1 + $P*$i]
            tclout err [expr $arg1 + $P*$i]
            set NORMERR1 [ expr $NORM - [lindex $xspec_tclout 0] ]
            set NORMERR2 [ expr [lindex $xspec_tclout 1] - $NORM ]
            err [expr $arg2 + $P*$i]
            tclout err [expr $arg2 + $P*$i]
            set PHOTERR1 [ expr $PHOT - [lindex $xspec_tclout 0] ]
            set PHOTERR2 [ expr [lindex $xspec_tclout 1] - $PHOT ]
            set NORMDIV1 [expr $NORMERR1 * (10**(2-$PHOT) - 0.5**(2-$PHOT)) /\
                                                                     (2-$PHOT) ]
            set NORMDIV2 [expr $NORMERR2 * (10**(2-$PHOT) - 0.5**(2-$PHOT)) /\
                                                                     (2-$PHOT) ]
            set PHOTDIV1 [expr $PHOTERR1 * $NORM * ( ( (log(2) * ($PHOT-2) - 1) \
                            * 2**$PHOT * 10**$PHOT + 400 * log(10) *($PHOT - 2)\
                             + 400) / (4 * ($PHOT-2)**2.0 * 10**$PHOT) )]
            set PHOTDIV2 [expr $PHOTERR2 * $NORM * ( ( (log(2) * ($PHOT-2) - 1)\
                            * 2**$PHOT * 10**$PHOT + 400 * log(10) *($PHOT - 2)\
                                 + 400) / (4 * ($PHOT-2)**2.0 * 10**$PHOT) )]
            set XERR1 [expr sqrt( $NORMDIV1**2.0 + $PHOTDIV1**2.0 ) * $KEV]
            set XERR2 [expr sqrt( $NORMDIV2**2.0 + $PHOTDIV2**2.0 ) * $KEV]
        } elseif {$arg0 == -4} {
        	tclout par [expr $arg1 + $P*$i]
        	set NORM [lindex $xspec_tclout 0]
        	tclout par [expr $arg2 + $P*$i]
        	set PHOT [lindex $xspec_tclout 0]
        	set XVAL [expr ($NORM*($arg5**(2-$PHOT) - $arg4**(2-$PHOT))/\
                                                               (2-$PHOT))* $KEV]
            err [expr $arg1 + $P*$i]
            tclout err [expr $arg1 + $P*$i]
            set NORMERR1 [ expr $NORM - [lindex $xspec_tclout 0] ]
            set NORMERR2 [ expr [lindex $xspec_tclout 1] - $NORM ]
            err [expr $arg2 + $P*$i]
            tclout err [expr $arg2 + $P*$i]
            set PHOTERR1 [ expr $PHOT - [lindex $xspec_tclout 0] ]
            set PHOTERR2 [ expr [lindex $xspec_tclout 1] - $PHOT ]
            puts "$NORM $NORMERR1 $NORMERR2 $PHOT $PHOTERR1 $PHOTERR2"
            set NORMDIV1 [expr $NORMERR1 * ($arg5**(2-$PHOT) \
                                - $arg4**(2-$PHOT)) / (2-$PHOT) ]
            set NORMDIV2 [expr $NORMERR2 * ($arg5**(2-$PHOT) \
                                - $arg4**(2-$PHOT)) / (2-$PHOT) ]
            set PHOTDIV1 [expr $PHOTERR1 * $NORM * \
                            ( ( ( $arg5**(2-$PHOT) - $arg4**(2-$PHOT) ) /\
                            ( (2-$PHOT)**2.0 ) ) +  ( ( ( $arg4**(2-$PHOT))\
                            *log($arg4) - ($arg5**(2-$PHOT))*log($arg5) ) /\
                            (2-$PHOT) ) )]
            set PHOTDIV2 [expr $PHOTERR2 * $NORM * \
                            ( ( ( $arg5**(2-$PHOT) - $arg4**(2-$PHOT) ) /\
                            ( (2-$PHOT)**2.0 ) ) +  ( ( ( $arg4**(2-$PHOT))\
                            *log($arg4) - ($arg5**(2-$PHOT))*log($arg5) ) /\
                            (2-$PHOT) ) )]
            set XERR1 [expr sqrt( $NORMDIV1**2.0 + $PHOTDIV1**2.0 ) * $KEV]
            set XERR2 [expr sqrt( $NORMDIV2**2.0 + $PHOTDIV2**2.0 ) * $KEV]
        }

        append XVALS " " $XVAL
        append XERRS1 " " $XERR1
        append XERRS2 " " $XERR2

        if {$arg1 > 0} {
            tclout par [expr $arg1 + $P*$i]
            set YVAL [lindex $xspec_tclout 0]
            tclout err [expr $arg1 + $P*$i]
            set YERR1 [ expr $YVAL - [lindex $xspec_tclout 0] ]
            set YERR2 [ expr [lindex $xspec_tclout 1] - $YVAL ]
	    } elseif {$arg1 <= 0} {
        	tclout flux [expr $i + 1]
        	set YVAL [lindex $xspec_tclout 0]
        	set YERR1 [lindex $xspec_tclout 1]
            set YERR2 $YERR1
        } 
        append YVALS " " $YVAL
        append YERRS1 " " $YERR1
        append YERRS2 " " $YERR2

        incr i
    }

    global PYSCRIPT_ROUTE # Take this variable from the global namespace

    exec $PYSCRIPT_ROUTE/xspecSave.py \
            x $XVALS y $YVALS xerr1 $XERRS1 xerr2 $XERRS2  \
                yerr1 $YERRS1 yerr2 $YERRS2 fname $FNAME

}

# extractabs - save the flux and absorption fraction of each spectrum
#
# - Takes a single argument giving the component number of the absorption
#   component whose effect is to be extracted. The fractional change in the
#   flux of each spectrum is recorded alongside its unabsorbed flux. A second
#   argument can optionally be given to specify the name of the output file,
#   otherwise the default name 'multiComp.dat' will be used. E.g. for the model
#   'wabs x pow', so that the first component is the absorbing component:
#
#       extractabs 1           - save the absorption fraction and flux
#       extractabs 1 'abs.dat' - save the absorption fraction and flux in the 
#                                file 'abs.dat'
#
proc extractabs {{arg0 1} {arg1 none}} {

    save mo tempModelSave.xcm

    # get number of spectra, model params
    tclout datasets
    set N $xspec_tclout

    set i 1


    flux 0.5 10.0

    while { $i <= $N } {
	    tclout flux $i
        lappend MODB [lindex $xspec_tclout 0]
        incr i
    }
    
    delcomp $arg0
    flux 0.5 10.0

    set i 1
    while { $i <= $N } {
	    tclout flux $i
        echo $xspec_tclout $MODB
        lappend ABS [expr [lindex $MODB [expr $i-1]] / [lindex $xspec_tclout 0]]
        lappend FLUX  [lindex $xspec_tclout 0]
        incr i
    }

    @tempModelSave.xcm
    exec rm tempModelSave.xcm

    echo $ABS >> multiComp.dat
    echo $FLUX >> multiComp.dat

}

