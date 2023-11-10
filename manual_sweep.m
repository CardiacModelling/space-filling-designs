function [best_params, best_score] = manual_sweep(ICs, box_hits, Model_Params)

durations = [25 50 100 200 500 1000]';
N_boxes = size(box_hits,1);
distance_to_box_centre = (180/N_boxes)/2.0; % Voltage range/num boxes
voltages = linspace(-120+distance_to_box_centre,60-distance_to_box_centre,N_boxes)'; % V in middle of the boxes

best_score = 10000;

for i = 1:length(durations)
    for j = 1:length(voltages)
        for k = 1:length(durations)
            for l = 1:length(voltages)
                for m = 1:length(durations)
                    for n = 1:length(voltages)
                        fprintf('%i, %i, %i, %i, %i, %i\n',i,j,k,l,m,n)
                        step_params = [durations(i) voltages(j) durations(k) voltages(l) durations(m) voltages(n)];
                        score = step_param_objective(step_params,ICs,box_hits,Model_Params,true);
                        
                        if score < best_score
                            best_score = score;
                            best_params = step_params;
                        end
                    end
                end
            end
        end
    end
end
