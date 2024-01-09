function [total_hits, total_duration] = plot_a_generated_protocol(filename, varargin)
    % PlotAGeneratedProtocol This gives a slightly different (lower) number of 
    % boxes because it outputs just before each step, and then 1ms after, as 
    % opposed to the design script which includes the step itself. This one, 
    % missing 1ms after the steps is probably a more realistic interpretation 
    % of what you might be able to measure (in fact, we probably want to chop 
    % out a whole 5ms and re-examine as usual to account for capacitive spikes).

    if nargin==2
        simple_plots = varargin{1};
    else
        simple_plots = true;
    end
    
    addpath("tight_subplot")

    % Protocol to plot
    clamps = load(filename);
    
    % Model parameters
    load('each_cell_params.mat')
    Model_Params = each_cell_params(:,5); % Cell 5
    
    % The standard steps at the beginning defined to interpolate:
    start_clamp = [ 0 -80
        250 -80.0
        250 -120
        300 -120
        700 -80
        900 -80
        900 40
        1900 40
        1900 -120
        2400 -120 ];
    
    
    full_clamp = start_clamp;
    t = [0];
    V = [-80];
    y = [0.00017    0.601]; % Steady state for -80mV
    
    next_time_add = 0;
    for i=1:length(clamps)
        last_time = full_clamp(end,1)+next_time_add;
        if isnan(clamps(i,2))
            % This is the way we do ramps, works fine!
            %disp(['Found a Nan on line ' num2str(i)])
            next_time_add = clamps(i,1);
            continue
        end
        
        start_point = [last_time clamps(i,2)];
        end_point = [last_time+clamps(i,1) clamps(i,2)];
        full_clamp = [full_clamp; start_point; end_point];
        next_time_add = 0;
    end
    
    end_time = full_clamp(end,1);
    
    end_clamp = [end_time+0.001	-80	
        end_time+1000 -80
        end_time+1000 40
        end_time+1500 40
        end_time+1500 -70
        end_time+1510 -70
        end_time+1610 -110
        end_time+1610 -120
        end_time+2000 -120
        end_time+2000 -80
        end_time+2500 -80];
    
    full_clamp = [full_clamp; end_clamp];
    
    options = odeset('AbsTol',1e-8,'RelTol',1e-8);
    [t,y]=ode15s(@model,[0 full_clamp(end,1)],y,options,full_clamp,Model_Params);
    % Phase plots
    a = y(:,1);
    r = y(:,2);
    V = getVoltage(t, full_clamp);
    
    colours = parula(length(t));
    set(groot,'defaultAxesTickLabelInterpreter','latex'); 
    
    figure
    ha = tight_subplot(4,1,.03,[.1 .02],[.1 .03]);
    axes(ha(1))
    hold all
    if simple_plots
        plot(t,V,'-','LineWidth',1.5)
    else
        for t_idx = 2:length(t)
            plot([t(t_idx-1) t(t_idx)],[V(t_idx-1) V(t_idx)],'-','Color',colours(t_idx,:),'LineWidth',1.5)
        end
    end
    ylabel('Voltage (mV)','interpreter','latex')
    set(gca,'FontSize',14,'Box','on')
    set(gca, 'XTickLabel', [])
    yticks(-120:40:40)
    yticklabels({"-120", "-80", "-40", "0", "+40"})
    ylim([-130 70])
    
    axes(ha(2))
    hold all
    if simple_plots
        plot(t,a,'-','LineWidth',1.5)
    else
        for t_idx = 2:length(t)
            plot([t(t_idx-1) t(t_idx)],[a(t_idx-1) a(t_idx)],'-','Color',colours(t_idx,:),'LineWidth',1.5)
        end
    end
    ylabel('Activation, $a$ gate','interpreter','latex')
    yticks([0 0.5 1])
    set(gca,'FontSize',14,'Box','on')
    set(gca, 'XTickLabel', [])
    yticklabels({"0", "0.5", "1"})
    
    axes(ha(3))
    hold all
    if simple_plots
        plot(t,r,'-','LineWidth',1.5)
    else
        for t_idx = 2:length(t)
            plot([t(t_idx-1) t(t_idx)],[r(t_idx-1) r(t_idx)],'-','Color',colours(t_idx,:),'LineWidth',1.5)
        end
    end
    ylabel('Recovery, $r$ gate','interpreter','latex')
    yticks([0 0.5 1])
    set(gca,'FontSize',14,'Box','on')
    set(gca, 'XTickLabel', [])
    yticklabels({"0", "0.5", "1"})
    
    IKr = Model_Params(end).*a.*r.*(V-(-88.6));
    axes(ha(4))
    plot([t(1) t(end)],[0 0],'k--')
    hold all
    if simple_plots
        plot(t,IKr,'-','LineWidth',1.5)
    else
    for t_idx = 2:length(t)
        plot([t(t_idx-1) t(t_idx)],[IKr(t_idx-1) IKr(t_idx)],'-','Color',colours(t_idx,:),'LineWidth',1.5)
    end
    end
    xlabel('Time (ms)','interpreter','latex','FontSize',16)
    set(gca,'FontSize',14,'Box','on')
    ylabel('IKr (nA)','interpreter','latex','FontSize',16)
    
    figure
    hold all
    if simple_plots
        plot3(a,r,V,'-','LineWidth',2)
    else
        for t_idx = 2:length(t)
            plot3([a(t_idx-1) a(t_idx)],[r(t_idx-1) r(t_idx)],[V(t_idx-1) V(t_idx)],'-','Color',colours(t_idx,:),'LineWidth',2)
        end
    end
    xlim([0 1])
    ylim([0 1])
    zlim([-120 60])
    xlabel('Activation, $a$ gate','interpreter','latex','FontSize',16)
    ylabel('Recovery, $r$ gate','interpreter','latex','FontSize',16)
    zlabel('Voltage (mV)','interpreter','latex','FontSize',16)
    zticks([-120 -90 -60 -30 0 30 60])
    xticks([0 0.5 1])
    yticks([0 0.5 1])
    
    N_boxes = 6;
    box_hits = zeros(N_boxes,N_boxes,N_boxes);
    box_hits = update_box_hits(box_hits, t, y, V);
    total_hits = sum(sum(sum(box_hits>1)));
    fprintf('This protocol hits %i/(%i^3) boxes (%.1f%%).\n',total_hits,N_boxes,100*total_hits/(N_boxes^3))
    
    hits = find(box_hits == 0);
    for i = 1:length(hits)
        [pos_i, pos_j, pos_k ] = ind2sub(size(box_hits),hits(i));
        highlight_box(pos_i, pos_j, pos_k)
    end
    set(gca,'FontSize',14,'Box','on')
    set(gcf,'Renderer','Painter')

    total_duration = t(end);
end

function highlight_box(i,j,k)

    x = [0 0 0 1 0 0; 0 0 1 1 0 1; 0 1 1 1 1 1; 0 1 0 1 1 0]; % The columns here are a vector of vertices for each face
    y = [1 0 1 1 1 1; 0 0 1 0 1 1; 0 0 0 0 1 0; 1 0 0 1 1 0];
    z = [1 0 1 1 0 0; 1 1 1 1 1 0; 0 1 1 0 1 0; 0 0 1 0 0 0] ;
    fill3((1/6).*(i-1) +(1/6).*x,(1/6).*(j-1)+(1/6).*y,-120 + 30.*(k-1) + 30.*z,'b','FaceAlpha',0.1, 'EdgeColor','none')

end