function [score] = ramp_param_objective(params,ICs,box_hits,Model_Params,printing)


assert(length(params)==5)

% Round durations to nearest ms
params(1) = ceil(params(1));
params(3) = ceil(params(3));
params(4) = ceil(params(4));

if printing; fprintf('Trying: V=%5.4g ramp to %5.4g mV for %g, %g, %g ms. ',params(2),params(5), params(1), params(3),params(4)); end

empty_original_boxes = length(find(box_hits()==0));

% Heavy penalty for steps that are out of voltage range...
upper_V = 60;
lower_V = -120;
if params(2) > upper_V
    score = 20000*(1+params(2)-upper_V);
    if printing; fprintf('Bad choice - V1 too high, score = %g.\n', score); end
    return
elseif params(2) < lower_V
    score = 20000*(1+lower_V-params(2));
    if printing; fprintf('Bad choice - V1 too low, score = %g.\n', score); end
    return
end
if params(5) > upper_V
    score = 20000*(1+params(5)-upper_V);
    if printing; fprintf('Bad choice - V3 too high, score = %g.\n', score); end
    return
elseif params(5) < lower_V
    score = 20000*(1+lower_V-params(5));
    if printing; fprintf('Bad choice - V3 too low, score = %g.\n', score); end
    return
end

% Penalty for step that is too short
min_duration = 20;
if (params(1) < min_duration)
    score = 50000*(1+min_duration-params(1));
    if printing; fprintf('Bad choice - 1st step too short, score = %g.\n', score); end
    return
end
if (params(3) < min_duration)
    score = 50000*(1+min_duration-params(3));
    if printing; fprintf('Bad choice - 2nd step too short, score = %g.\n', score); end
    return
end
if (params(4) < min_duration)
    score = 50000*(1+min_duration-params(4));
    if printing; fprintf('Bad choice - 3rd step too short, score = %g.\n', score); end
    return
end

[t, V, y] = run_ramp_clamp(ICs, Model_Params, params);

box_hits = update_box_hits(box_hits, t,y,V);

long_steps_penalty = params(1)+params(3)+params(4);

empty_boxes_now = length(find(box_hits()==0));
num_new_boxes = empty_original_boxes - empty_boxes_now;

score = -1000*num_new_boxes + long_steps_penalty;

if printing; fprintf('This visits %i new boxes, score = %g.\n',num_new_boxes,score); end
end

