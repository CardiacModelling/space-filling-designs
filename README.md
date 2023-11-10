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

