# Space-filling optimal experimental designs for measuring ion channel kinetics
Phase-voltage space filling optimal designs in Matlab

These are all Matlab scripts, tested on MATLAB R2023b.

## Prerequisities

First download the file `cmaes.m` [from Nikolaus Hansen's website](https://cma-es.github.io/cmaes.m) under a GPL licence, and add that to this source code directly in the top level directory. Version `3.61.beta` was used for the paper results.

## Running designs

The script `sequential_step_box_fill_script.m` runs a complete optimal experimental design. It uses the CMA-ES package to run optimisation of a cost function based on counting the number of discretised 'boxes' in the 3D phase-voltage space of the two gate Hodgkin-Huxley model for IKr from [Beattie et al. (2018)](https://doi.org/10.1113/JP275733)

## Stored designs

The folder `resulting_designs_2024` contains the 100 runs that feature in the paper that were generated with this version of the source code. 
The folder `resulting_designs_2019` contains the protocols that resulted from running an earlier version of the script above repeatedly for the 2019 SyncroPatch Challenge exercise at the Isaac Newton Institute's [Fickle Heart programme](https://www.newton.ac.uk/event/fht/).

## Plotting the results

The script `plot_a_generated_protocol.m` will plot a given protocol (based on filename to change at the top of it) and print out how many boxes it visits. Similarly `example_sine_wave_run.m` does this for the sinusoidal voltage clamp from Beattie et al. (2018), and `example_staircase_run.m` does it for the Lei et al. (2019) staircase protocol.

## Exporting for Nanion SyncroPatch

The python script `for_nanion_data_export/gary2txt.py` will create a text file for easier conversion to Nanion `.eph` SyncroPatch format. 

## Other files 

 * `plot_starting_steps.m` plots Figure 4.

 * The scripts `example_sine_wave_run.m` and `example_staircase_run.m` show the number of boxes hit by these previous designs. The identifiability folder contains fitting results taken directly from [https://github.com/CardiacModelling/empirical_quantification_of_model_discrepancy](https://github.com/CardiacModelling/empirical_quantification_of_model_discrepancy) 
in a spreadsheet to get the percentage error calculations in the Results->Identifiability section.

 * `find_best_schemes.m` analyses the 100 stored designs and plots Figures 5, 6 and 7, and prints out LaTeX for Table 2.

 * In the folder `play_with_6_steps_and_ramps` --- in addition to the step protocols that feature in the paper, you will also find the code can do designs with ramps `sequential_ramp_box_fill_script.m` (based on designing with 3 steps separated by two ramps instead of 3 steps with instant jumps between them). This does result in some nice waveforms and current responses, but doesn't seem to visit any more boxes, and so is left for people to use if they wish. There is also a script `sequential_6_step_box_fill_script.m` which does the six-at-a-time exercise mentioned in the discussion (doesn't seem to improve on three-at-a-time).

 * `look_at_time_constants.m` - simply plots the a and r steady state and time constant curves as a function of voltage.
