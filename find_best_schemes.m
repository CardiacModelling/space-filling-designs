close all
clear all

% results_dir = 'resulting_designs_2019';
results_dir = 'resulting_designs_2024';
% results_dir = 'play_with_6_steps_and_ramps/6_step_designs';
% results_dir = 'play_with_6_steps_and_ramps/step_ramp_designs';

listing = dir(results_dir);

scores = [];
durations = [];
names = {};
counter = 1;
for i = 1:length(listing)

    if listing(i).isdir == 1
        continue
    end
    if listing(i).name(1) == '.'
        continue
    end
    if listing(i).name(end-3:end) ~= ".txt"
        continue
    end

    fprintf("Protocol: %s\n",listing(i).name)
    [scores(counter) durations(counter)] = plot_a_generated_protocol([results_dir filesep listing(i).name]);
    names{counter} = listing(i).name;
    counter = counter + 1;
    title(listing(i).name,'Interpreter','none')
    close all
end

% figure
% subplot(1,3,1)
% hist(100.*scores/6^3)
% xlabel('Percentage of boxes visited')
% ylabel('Frequency')
% 
% subplot(1,3,2)
% hist(durations)
% xlabel('Duration of protocol (s)')
% ylabel('Frequency')
% 
% subplot(1,3,3)
% scatter(100.*scores/6^3, durations)
% xlabel('Percentage of boxes visited')
% ylabel('Duration of protocol (s)')

figure
scatterhistogram(100.*scores/6^3,durations,"NumBins",12,"Color",'b','FontSize',16,"HistogramDisplayStyle","bar")
xlabel('Boxes visited (%)')
ylabel('Duration of protocol (seconds)')
xlim([73 83])
ylim([8 12])

[s,ordering] = sort(scores);
best_score = s(end);
idx = ordering(end);
fprintf("Best protocol is %s which visits %i boxes.\n",names{ordering(end)}, s(end))
fprintf("2nd Best protocol is %s which visits %i boxes.\n",names{ordering(end-1)}, s(end-1))
fprintf("3rd Best protocol is %s which visits %i boxes.\n",names{ordering(end-2)}, s(end-2))
fprintf("4th Best protocol is %s which visits %i boxes.\n",names{ordering(end-3)}, s(end-3))
fprintf("5th Best protocol is %s which visits %i boxes.\n",names{ordering(end-4)}, s(end-4))

% For nice axis scalings
low_V = -130;
high_V = 70;
EKr = -88.6;
proportion_negative = (EKr-low_V)./(high_V - low_V);
% Low current
low_I = -3.2;
high_I = -low_I/proportion_negative + low_I;

figure
ha = tight_subplot(5,2,.03,[.1 .06],[.1 .1]);
axes(ha(1))
hold all
counter = 1;
% These are the best 5 protocols:
for i=length(ordering):-1:length(ordering)-4
    filename = [results_dir filesep names{ordering(i)}];
    [a b traces] = plot_a_generated_protocol(filename, false);
    traces(:,1) = traces(:,1)./1000.0;
    % Full protocol
    axes(ha(counter))
    yyaxis left
    if counter==1
        zoom_region = [5.3 5.8];
    elseif counter==3
        zoom_region = [5 5.8];
    elseif counter==5
        zoom_region = [6.7 7.2];
    elseif counter==7
        zoom_region = [6.7 8.4];
    elseif counter==9
        zoom_region = [5.45 6.27];
    end
    patch([zoom_region(1) zoom_region(2) zoom_region(2) zoom_region(1)],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
    hold on
    plot(traces(:,1), traces(:,2),'-','LineWidth',1)
    ylim([low_V high_V])
    yticks(-120:40:40)
    yticklabels({'-120\,mV', '-80\,mV', '-40\,mV', '0\,mV','40\,mV'})
    hold on
    yyaxis right
    plot([0 traces(end,1)],[0 0], '-' , 'Color',[0.6; 0.6; 0.6])
    plot(traces(:,1), traces(:,3), '-','LineWidth',1.5)
    xlim([0 traces(end,1)])
    ylim([low_I high_I])
    yticks(0:5:15)
    yticklabels({'','','',''})
    xticks(0:1:11)
    xticklabels('auto')
    if counter==1
        title('Full Protocol','Interpreter','latex')
    end
    if i==length(ordering)-4
        
        xlabel('Time (s)','FontSize',16,'Interpreter','latex')
    end
    set(gca,'Fontsize',14,'Box','on')
    counter = counter + 1;


    % Zoomed regions
    axes(ha(counter))
    yyaxis left
    plot(traces(:,1), traces(:,2),'-','LineWidth',1)
    ylim([low_V high_V])
    yticks(-120:40:40)
    yticklabels({'', '', '', '',''})
    hold on
    yyaxis right
    plot([0 traces(end,1)],[0 0], '-' , 'Color',[0.6; 0.6; 0.6])
    plot(traces(:,1), traces(:,3), '-','LineWidth',1.5)
    ylim([low_I high_I])
    yticks(0:5:15)
    xticklabels('auto')
    yticklabels({'0\,nA','5\,nA','10\,nA','15\,nA'})
    if i==length(ordering)-4
        xlabel('Time (s)','FontSize',16,'Interpreter','latex')
    end
    set(gca,'Fontsize',14,'Box','on')
    if counter==2
        title('Zoomed Region','Interpreter','latex')
    end
    xlim(zoom_region)
    clamps(:,counter-1:counter) = load(filename);
    counter = counter + 1;
end

set(gcf,'Renderer','Painter')
fprintf('')
fprintf('Step & t (ms) & V (mV) & t (ms) & V(mV) & t (ms) & V (mV) & t (ms) & V (mV) & t (ms) & V (mV)\n')
for i=1:size(clamps,1)
fprintf('%i & $%g$ & $%g$ & $%g$ & $%g$ & $%g$ & $%g$ & $%g$ & $%g$ & $%g$ & $%g$\\\\ \n', i, clamps(i,:))
end
% Make the size nice then run the below!
%exportgraphics(gcf,'for_writeup/5_best.pdf');