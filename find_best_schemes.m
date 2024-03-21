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
zoom1_start = 5750;
zoom1_end = 6325;
zoom2_start = 5350;
zoom2_end = 6100;
% These are the best 5 protocols:
for i=length(ordering):-1:length(ordering)-4
    filename = [results_dir filesep names{ordering(i)}];
    [a b traces] = plot_a_generated_protocol(filename, false);
    % Full protocol
    axes(ha(counter))
    yyaxis left
    if counter==1
        patch([zoom1_start zoom1_end zoom1_end zoom1_start],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==3
        patch([zoom2_start zoom2_end zoom2_end zoom2_start],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==5
        patch([5800 7200 7200 5800],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==7
        patch([5600 6900 6900 5600],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
    end
    if counter==9
        patch([6550 6900 6900 6550],[low_V low_V high_V-1 high_V-1],[0.9 0.9 0.9],'EdgeColor','none')
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
    xlim([0 10250])
    ylim([low_I high_I])
    yticks(0:5:15)
    yticklabels({'','','',''})
    if counter==1
        title('Full Protocol','Interpreter','latex')
    end
    xticks(0:1000:10000)
    xticklabels({'0', '1','2','3','4','5','6','7','8','9','10'})
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
    xlim([0 10500])
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
        xlim([zoom1_start zoom1_end])
        xticks(5800:100:6300)
        xticklabels({'5.8','5.9','6.0','6.1','6.2','6.3'})
    end
    if counter==4
        xlim([zoom2_start zoom2_end])
        xticks(5400:100:6100)
        xticklabels({'5.4','5.5','5.6','5.7','5.8','5.9','6.0','6.1'})
    end
    if counter==6
        xlim([5800 7200])
        xticks(5800:200:7200)
    xticklabels({'5.8','6.0','6.2','6.4','6.6','6.8','7.0','7.2'})
    end
    if counter==8
        xlim([5600 6900])
        xticks(5600:200:6800)
    xticklabels({'5.6','5.8','6.0','6.2','6.4','6.6','6.8'})
    end
    if counter==10
        xlim([6550 6900])
        xticks(6600:100:6900)
        xticklabels({'6.6','6.7','6.8','6.9'})
    end
    clamps(:,counter-1:counter) = load(filename);
    counter = counter + 1;
end
set(gcf,'Renderer','Painter')
fprintf('')
fprintf('Step & t (ms) & V (mV) & t (ms) & V(mV) & t (ms) & V (mV) & t (ms) & V (mV) & t (ms) & V (mV)\n')
for i=1:size(clamps,1)
fprintf('%i & %g & %g & %g & %g & %g & %g & %g & %g & %g & %g\\\\ \n', i, clamps(i,:))
end
% Make the size nice then run the below!
%exportgraphics(gcf,'for_writeup/5_best.pdf');