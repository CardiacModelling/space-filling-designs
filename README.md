# Space-filling optimal experimental designs for measuring ion channel kinetics
Phase-voltage space filling optimal designs in Matlab

These are all Matlab scripts, tested on MATLAB R2023b.

## Running designs

The script `sequential_step_box_fill_script.m` runs a complete optimal experimental design. It uses the CMA-ES package to run optimisation of a cost function based on counting the number of discretised 'boxes' in the 3D phase-voltage space of the two gate Hodgkin-Huxley model for IKr from [Beattie et al. (2018)](https://doi.org/10.1113/JP275733)

## Stored designs from 2019 runs

The folder `resulting_designs_2019` contains the protocols that resulted from running the script above repeatedly for the 2019 SyncroPatch Challenge exercise at the Isaac Newton Institute's Fickle Heart programme.

## Plotting the results

The script `plot_a_generated_protocol.m` will plot a given protocol (based on filename to change at the top of it) and print out how many boxes it visits. Similarly `example_sine_wave_run.m` does this for the sinusoidal voltage clamp from Beattie et al. (2018).

## Exporting for Nanion SyncroPatch

The python script `for_nanion_data_export/gary2txt.py` will add the final 'reversal ramp' portions of the protocol, then it creates a text file that can be read by [txt2eph.py](https://github.com/CardiacModelling/nanion-data-export/blob/master/txt2eph.py) for conversion to Nanion .eph format. 

## Other files for context

The scripts `example_sine_wave_run.m` and `example_staircase_run.m` show the number of boxes hit by these previous designs. The identifiability folder contains fitting results taken directly from [https://github.com/CardiacModelling/empirical_quantification_of_model_discrepancy](https://github.com/CardiacModelling/empirical_quantification_of_model_discrepancy) 
in a spreadsheet to get the percentage error calculations in the Results->Identifiability section

## TODO!

Before public release!

The cmaes.m that is included here is under a copyleft GPL licence, so we can't licence all this as BSD as usual. We should probably just make this project a GPL licence too (can't see it wanting to be commercialised). Alternatively we keep our licence and tell people they have to go and download the cmaes.m separately as a prerequisite, but that's annoying.
