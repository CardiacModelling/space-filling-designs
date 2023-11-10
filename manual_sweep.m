function best_params = manual_sweep(ICs, box_hits, Model_Params)

durations = [25 50 100 200 500 1000]';
voltages = linspace(-115,55,6)';

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

best_params




