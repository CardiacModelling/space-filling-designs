close all
clear all

% Parameters to tweak
N_boxes = 6; % in each dimension.u
N_steps = 17; % sets of 3 steps...
optimise = true; % Brute force sweep if false.
print_lots = false; % Display output of every objective call
num_to_generate = 20;

%
load('each_cell_params.mat')
Model_Params = each_cell_params(:,5); % Loads up Beattie et al. (2018) Cell #5 parameters.

% This is a little trick to stop matlab stealing focus
% https://uk.mathworks.com/matlabcentral/answers/398905-how-to-keep-matlab-from-stealing-focus
fig1 = figure(1);
fig2 = figure(2);
% and then use set(0,'CurrentFigure',fg);


for z = 1:num_to_generate

    box_hits = zeros(N_boxes,N_boxes,N_boxes); % main counter of number of timepoints we spend in each box
    
    % The standard steps at the beginning defined as a table to interpolate from:
    clamp = [ 0 -80
        250 -80.0
        250.00001 -120
        300 -120
        700 -80
        900 -80
        900.0001 40
        1900 40
        1900.0001 -120
        2400 -120 ];
    
    t = [0];
    V = [-80];
    y = [0.00017    0.601]; % Steady state for -80mV
    
    
    % Run through the predefined first steps and record box hits.
    options = odeset;
    [t,y]=ode15s(@model,[0:1:clamp(end,1)],y,options,clamp,Model_Params);
    V = interp1(clamp(:,1),clamp(:,2),t,'linear',-80);
    box_hits = update_box_hits(box_hits, t, y, V);
    
    set(0,'CurrentFigure', fig1)
    subplot(4,1,1)
    plot(t,V,'k-','LineWidth',2);
    xlabel('Time (ms)')
    ylabel('V (mV)')
    
    subplot(4,1,2)
    plot(t,y(:,1),'b-','LineWidth',2)
    hold on
    plot(t,y(:,2),'g-','LineWidth',2)
    legend('a','r','AutoUpdate','off')
    xlabel('Time (ms)')
    ylabel('Gating variable')
    
    
    IKr = Model_Params(end).*y(:,1).*y(:,2).*(V-(-88.6));
    
    subplot(4,1,3)
    plot([t(1) t(end)],[0 0],'k--')
    hold on
    plot(t,IKr,'b-','LineWidth',2)
    hold off
    xlabel('Time (ms)')
    ylabel('$I_{Kr}$','Interpreter','latex')
    
    a = y(:,1);
    r = y(:,2);
    
    subplot(4,1,4)
    plot(a,r,'b-','LineWidth',2)
    xlabel('activation a')
    ylabel('recovery r')
    
    set(0,'CurrentFigure', fig2)
    plot3(a,r,V,'b-','LineWidth',2)
    xlabel('activation a')
    ylabel('recovery r')
    zlabel('Voltage (mV)')
    
    ICs = y(end,:);
    
    % For initial guesses - [duration1, v1, duration2, v2, duration3, v3].
    lower_bounds = [30; -120; 30; -120; 30; -120];
    ranges = [1000;180;1000;180;1000;180];
    sigma_guess = [100;20;100;20;100;20];
    cmaes_options = cmaes('defaults');
    cmaes_options.TolX = 2;
    
    All_Params = []; % matrix to store all the steps in
    total_score=0;
    for step_n = 1:N_steps
        
        if optimise
            
            % Have an initial look around for good places
            best_score = 1e10;
            N_guesses=1000;
            fprintf('Trying %i random guesses to get good start points for round %i/%i.\n',N_guesses,step_n, N_steps)
            tic
            for i=1:N_guesses
                random_guess = lower_bounds+rand(length(lower_bounds),1).*ranges;
                score = step_param_objective(random_guess, ICs, box_hits, Model_Params, false);
                if score < best_score
                    fprintf('Guess %i/%i got a new best score of %f.\n',i,N_guesses,score)
                    param_guess = random_guess;
                    best_score = score;
                end
            end
            toc
            
            % Have ten tries
            tries = 10;
            for i=1:tries
                [~,~,~,~,~,bestever] = cmaes('step_param_objective',param_guess,sigma_guess,cmaes_options,ICs, box_hits, Model_Params, print_lots);
                score = bestever.f;
                if score<best_score
                    break
                end
                if i==tries
                    fprintf("Optimisation failed %g times. Using the random guess instead.\n", tries)
                    bestever.f = best_score
                    bestever.x = param_guess
                    warning("CMA-ES didn't do any better than the initial guess")
                end
            end
            total_score = total_score+score;
            Step_Params = bestever.x;
            Step_Params(1) = ceil(Step_Params(1)); % round to nearest ms
            Step_Params(3) = ceil(Step_Params(3));
            Step_Params(5) = ceil(Step_Params(5));
        else
            Step_Params, score = manual_sweep(ICs, box_hits, Model_Params);
            total_score = total_score+score;
        end
        
        if (Step_Params(1) < 10 || Step_Params(3) < 10 || Step_Params(5) < 10)
            error('steps too small') % sanity check - shouldn't ever throw
        end
        
        % Run again with selected best params to record everything
        [t_run, V_run, y_run] = run_3_step_clamp(ICs, Model_Params, Step_Params);
        a_run = y_run(:,1);
        r_run = y_run(:,2);
        
        % Update the number of box hits in these new 3 steps
        old_hits = box_hits;
        box_hits = update_box_hits(box_hits, t_run, y_run, V_run);
        empty_original_boxes = length(find(old_hits()==0));
        empty_boxes_now = length(find(box_hits()==0));
        number_new_boxes = empty_original_boxes - empty_boxes_now;
        fprintf("\n 3 step design complete, it added %i new boxes.\n\n",number_new_boxes)
    
        % Store end state
        ICs = y_run(end,:);
        
        % Append the parameters for these 3 steps to the end of the step collection
        All_Params = [All_Params; Step_Params(1) Step_Params(2); Step_Params(3) Step_Params(4); Step_Params(5) Step_Params(6)];
        
        % Append the variables for these 3 steps to the previous ones
        t = [t; t_run+t(end)];
        y = [y; y_run];
        V = [V; V_run];
        a = y(:,1);
        r = y(:,2);
        
        
        % Plot in loop to highlight new 3 steps
        set(0, 'CurrentFigure', fig1)
        subplot(4,1,1)
        plot(t, V,'k-','LineWidth',2)
        hold on
        plot(t(end-length(t_run)+1:end), V_run,'r-','LineWidth',2)
        hold off
        xlabel('Time (ms)')
        ylabel('V (mV)')
        
        subplot(4,1,2)
        plot(t,y(:,1),'b-', 'LineWidth',2)
        hold on
        plot(t,y(:,2),'g-','LineWidth',2)
        legend('a','r','AutoUpdate','off')
        plot(t(end-length(t_run)+1:end),y(end-length(t_run)+1:end,1),'r-','LineWidth',2)
        plot(t(end-length(t_run)+1:end),y(end-length(t_run)+1:end,2),'r-','LineWidth',2)
        hold off
        xlabel('Time (ms)')
        ylabel('Gating variable')
        
        IKr = Model_Params(end).*y(:,1).*y(:,2).*(V-(-88.6));
        IKr_step = Model_Params(end).*y_run(:,1).*y_run(:,2).*(V_run-(-88.6));
        
        subplot(4,1,3)
        plot([t(1) t(end)],[0 0],'k-')
        hold on
        plot(t,IKr,'b-','LineWidth',2)
        plot(t(end-length(t_run)+1:end),IKr_step,'r-','LineWidth',2)
        hold off
        xlabel('Time (ms)')
        ylabel('$I_{Kr}$','Interpreter','latex')
        
        subplot(4,1,4)
        plot(a,r,'b-','LineWidth',2)
        hold on
        plot(a_run, r_run, 'r-','LineWidth',2)
        hold off
        xlabel('activation a')
        ylabel('recovery r')
        
        set(0,'CurrentFigure', fig2)
        plot3(a,r,V,'b-','LineWidth',2)
        hold on
        plot3(a_run,r_run,V_run,'r-','LineWidth',2)
        hold off
        xlim([0 1])
        ylim([0 1])
        zlim([-120 60])
        xlabel('Activation, $a$ gate','interpreter','latex')
        ylabel('Recovery, $r$ gate','interpreter','latex')
        zlabel('Voltage (mV)','interpreter','latex')
        zticks([-120 -90 -60 -30 0 30 60])
        
        drawnow
    end
    
    disp('Protocol: Duration (ms), Voltage (mV)')
    All_Params
    total_hits = sum(sum(sum(box_hits>1)));

    Filename = sprintf('%s_%i_box_%i_step_Space_Filling_Params_%g_%g.txt', datestr(now,'yyyy-mm-dd-HH-MM'),N_boxes, N_steps, total_hits, total_score)
    fprintf('Design %s is complete.\nIt visited %i/%i boxes (%.1f%%) and got a total score of %f\n', Filename, total_hits, N_boxes^3, 100*total_hits/(N_boxes^3),total_score)
    save(Filename,'All_Params','-ascii')

end

