function [score] = six_step_param_objective(params,ICs,box_hits,Model_Params,printing)

    assert(length(params)==12)

    % Round durations and voltages up to nearest ms or mV
    params = ceil(params);

    if printing; fprintf('Trying: V=%5.4g, %5.4g, %5.4g mV for %g, %g, %g ms. ',params(2),params(4),params(6), params(1), params(3),params(5)); end
    if printing; fprintf('plus  : V=%5.4g, %5.4g, %5.4g mV for %g, %g, %g ms. ',params(8),params(10),params(12), params(7), params(9),params(11)); end

    empty_original_boxes = length(find(box_hits()==0));

    % Heavy penalty for steps that are out of voltage range...
    upper_V = 60;
    lower_V = -120;
    penalty_score = 0;
    if params(2) > upper_V
        penalty_score = penalty_score + 20000*(1+params(2)-upper_V);
        if printing; fprintf('Bad choice - V1 too high, score = %g.\n', penalty_score); end
    elseif params(2) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(2));
        if printing; fprintf('Bad choice - V1 too low, score = %g.\n', penalty_score); end
    end
    if params(4) > upper_V
        penalty_score = penalty_score + 20000*(1+params(4)-upper_V);
        if printing; fprintf('Bad choice - V2 too high, score = %g.\n', penalty_score); end
    elseif params(4) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(4));
        if printing; fprintf('Bad choice - V2 too low, score = %g.\n', penalty_score); end
    end
    if params(6) > upper_V
        penalty_score = penalty_score + 20000*(1+params(6)-upper_V);
        if printing; fprintf('Bad choice - V3 too high, score = %g.\n', penalty_score); end
    elseif params(6) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(6));
        if printing; fprintf('Bad choice - V3 too low, score = %g.\n', penalty_score); end
    end
    if params(8) > upper_V
        penalty_score = penalty_score + 20000*(1+params(8)-upper_V);
        if printing; fprintf('Bad choice - V4 too high, score = %g.\n', penalty_score); end
    elseif params(8) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(8));
        if printing; fprintf('Bad choice - V4 too low, score = %g.\n', penalty_score); end
    end
    if params(10) > upper_V
        penalty_score = penalty_score + 20000*(1+params(10)-upper_V);
        if printing; fprintf('Bad choice - V5 too high, score = %g.\n', penalty_score); end
    elseif params(10) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(10));
        if printing; fprintf('Bad choice - V5 too low, score = %g.\n', penalty_score); end
    end
    if params(12) > upper_V
        penalty_score = penalty_score + 20000*(1+params(12)-upper_V);
        if printing; fprintf('Bad choice - V6 too high, score = %g.\n', penalty_score); end
    elseif params(12) < lower_V
        penalty_score = penalty_score + 20000*(1+lower_V-params(12));
        if printing; fprintf('Bad choice - V6 too low, score = %g.\n', penalty_score); end
    end
    
    % Penalty for step that is too short
    min_duration = 20;
    if (params(1) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(1));
        if printing; fprintf('Bad choice - 1st step too short, score = %g.\n', penalty_score); end
    end
    if (params(3) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(3));
        if printing; fprintf('Bad choice - 2nd step too short, score = %g.\n', penalty_score); end
    end
    if (params(5) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(5));
        if printing; fprintf('Bad choice - 3rd step too short, score = %g.\n', penalty_score); end
    end
    if (params(7) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(7));
        if printing; fprintf('Bad choice - 4th step too short, score = %g.\n', penalty_score); end
    end
    if (params(9) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(9));
        if printing; fprintf('Bad choice - 5th step too short, score = %g.\n', penalty_score); end
    end
    if (params(11) < min_duration)
        penalty_score = penalty_score + 50000*(1+min_duration-params(11));
        if printing; fprintf('Bad choice - 6th step too short, score = %g.\n', penalty_score); end
    end

    % Durations
    for i=1:2:11
        % We can't have any negative durations!
        if params(i) <= 0 
            score = 1e12;
            return
        end
    end
    
    [t, V, y] = run_6_step_clamp(ICs, Model_Params, params);
    
    box_hits = update_box_hits(box_hits, t,y,V);
   
    long_steps_penalty = params(1)+params(3)+params(5)+params(7)+params(9)+params(11);

    empty_boxes_now = length(find(box_hits()==0));
    num_new_boxes = empty_original_boxes - empty_boxes_now;

    score = -1000*num_new_boxes + long_steps_penalty + penalty_score;


    if printing; fprintf('This visits %i new boxes, score = %g.\n',num_new_boxes,penalty_score); end
end

