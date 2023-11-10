import os
import numpy as np
import glob
import re

allfiles = glob.glob('./*Space_Filling_Params*')

savedir = './converted_space_filling_designs'
if not os.path.isdir(savedir):
    os.makedirs(savedir)

pretext = """\
Type	Voltage	Duration
Set 	-120	50
Ramp	-80	400
Set 	-80	200
Set 	40	1000
Set 	-120	500
Set 	-80	1000
"""

posttext = """\
Set 	-80	1000
Set 	40	500
Set 	-70	10
Ramp	-110	100
Set 	-120	390
Set 	-80	500
"""

ramp_steps = 13
total_steps = 64
allowed_steps = total_steps - ramp_steps

idxs = []
timestamps = []
scores = []
for i, f in enumerate(allfiles):
    timestamp, score = \
            re.findall('\.\/(.*)_Space_Filling_Params_(.*).txt', f)[0]
    idx = ('0%s' % (i + 1)) if i < 9 else str(i + 1)
    print(idx, timestamp, score)
    idxs.append(idx)
    timestamps.append(timestamp)
    scores.append(score)

    # Convert
    garyprotocol = np.loadtxt(f)

    # Count steps...
    garynsteps = len(garyprotocol)
    if garynsteps > allowed_steps:
        cutout = garynsteps - allowed_steps
        if cutout % 3:
            print('Chopping %s steps, not factor of 3...' % cutout)
        garyprotocol = garyprotocol[:-1*cutout, :]

    durations = garyprotocol[:, 0]
    voltages = garyprotocol[:, 1]

    with open('%s/SpaceFillingProtocol%s.txt' % (savedir, idx), 'w') as ff:
        ff.write(pretext)
        for v, d in zip(voltages, durations):
            ff.write('Set\t%.1f\t%.1f\n' % (v, d))
        ff.write(posttext)

# Save idx, timestamp, score
with open('%s/SpaceFillingProtocolIndices.csv' % savedir, 'w') as f:
    f.write('\"Index\",\"Timestamp\",\"Score\"\n')
    for i, t, s in zip(idxs, timestamps, scores):
        f.write(i + ',' + t + ',' + s + '\n')

