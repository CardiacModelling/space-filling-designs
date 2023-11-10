close all
clear all

results_dir = 'resulting_designs_2019';

listing = dir(results_dir)


scores = [];
counter = 1;
for i = 1:length(listing)

    if listing(i).isdir == 1 || listing(i).name(1) == '.'
        continue
    end

    scores(counter) = plot_a_generated_protocol([results_dir filesep listing(i).name]);
    counter = counter + 1;
end

figure
hist(100.*scores/6^3)
xlabel('Percentage of Boxes visited')
ylabel('Frequency')