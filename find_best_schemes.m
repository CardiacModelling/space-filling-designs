close all
clear all

results_dir = 'resulting_designs_2019';

listing = dir(results_dir)


scores = [];
durations = [];
counter = 1;
for i = 1:length(listing)

    if listing(i).isdir == 1
        continue
    end
    if listing(i).name(1) == '.'
        continue
    end
    if listing(i).name(end-3:end) == ".fig"
        continue
    end

    fprintf("Protocol: %s\n",listing(i).name)
    [scores(counter) durations(counter)] = plot_a_generated_protocol([results_dir filesep listing(i).name]);
    counter = counter + 1;
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