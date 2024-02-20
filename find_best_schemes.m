close all
clear all

results_dir = 'resulting_designs_2024';

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

figure
subplot(1,3,1)
hist(100.*scores/6^3)
xlabel('Percentage of Boxes visited')
ylabel('Frequency')

subplot(1,3,2)
hist(durations./1000)
xlabel('Duration of protocol (s)')
ylabel('Frequency')

subplot(1,3,3)
scatter(100.*scores/6^3, durations./1000)
xlabel('Percentage of Boxes visited')
ylabel('Duration of Protocol (s)')

[s,ordering] = sort(scores);
best_score = s(end);
idx = ordering(end);
[best_score idx] = max(scores);
fprintf("Best protocol is %s which visits %i boxes.\n",names{idx}, best_score)

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
    [a b traces] = plot_a_generated_protocol([results_dir filesep names{ordering(i)}]);
    % Full protocol
    axes(ha(counter))
    yyaxis left
    if counter==1
        patch([6950 7350 7350 6950],[low_V low_V high_V high_V],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==3
        patch([6350 7250 7250 6350],[low_V low_V high_V high_V],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==5
        patch([8100 8750 8750 8100],[low_V low_V high_V high_V],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==7
        patch([5000 6200 6200 5000],[low_V low_V high_V high_V],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==9
        patch([6500 6800 6800 6500],[low_V low_V high_V high_V],[0.9 0.9 0.9],'EdgeColor','none')
    end
    hold on
    plot(traces(:,1), traces(:,2),'-','LineWidth',1)
    ylim([low_V high_V])
    yticks(-120:40:40)
    yticklabels({'-120\,mV', '-80\,mV', '-40\,mV', '0\,mV','40\,mV'})
    hold on
    yyaxis right
    plot([0 12000],[0 0], '-' , 'Color',[0.6; 0.6; 0.6])
    plot(traces(:,1), traces(:,3), '-','LineWidth',1.5)
    xlim([0 11500])
    ylim([low_I high_I])
    yticks(0:5:15)
    yticklabels({'','','',''})
    if counter==1
        title('Full Protocol','Interpreter','latex')
    end
    xticks(0:1000:11000)
    xticklabels({'0', '1','2','3','4','5','6','7','8','9','10','11'})
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
    plot([0 12000],[0 0], '-' , 'Color',[0.6; 0.6; 0.6])
    plot(traces(:,1), traces(:,3), '-','LineWidth',1.5)
    xlim([0 11500])
    ylim([low_I high_I])
    yticks(0:5:15)

    yticklabels({'0\,nA','5\,nA','10\,nA','15\,nA'})
    if i==length(ordering)-4
        xlabel('Time (s)','FontSize',16,'Interpreter','latex')
    end
    set(gca,'Fontsize',14,'Box','on')
    if counter==2
        title('Zoomed Region','Interpreter','latex')
    end
    if counter==2
        xlim([6950 7350])
        xticks(6900:100:7400)
        xticklabels({'6.9','7.0','7.1','7.2','7.3','7.4'})
    end
    if counter==4
        xlim([6350 7250])
        xticks(6400:100:7200)
        xticklabels({'6.4','6.5','6.6','6.7','6.8','6.9','7.0','7.1','7.2'})
    end
    if counter==6
        xlim([8100 8750])
        xticks(8100:100:8700)
        xticklabels({'8.1','8.2','8.3','8.4','8.5','8.6','8.7'})
    end
    if counter==8
        xlim([5000 6200])
        xticks(5000:200:6200)
    xticklabels({'5.0','5.2','5.4','5.6','5.8','6.0','6.2'})
    end
    if counter==10
        xlim([6500 6800])
        xticks(6500:100:6800)
        xticklabels({'6.5','6.6','6.7','6.8'})
    end
    counter = counter + 1;
end
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [4 2]);
set(gcf,'Renderer','Painter')
exportgraphics(gcf,'for_writeup/5_best.pdf');