
clear all
% This was best protocol
[~, ~, beattie, wang ] = plot_a_generated_protocol('resulting_designs_2024/2024-04-26-05-06_6_box_17_step_Space_Filling_Params_151_-149084.txt');
close all

% First do a staircase run for both for comparison

load('each_cell_params.mat')
Model_Params = each_cell_params(:,5); % Loads up Beattie et al. (2018) Cell #5 parameters.
Protocol_Params = [54, 26, 10, 0.007/(2*pi), 0.037/(2*pi), 0.19/(2*pi)];
y0 = [0.00017    0.601]; % ICs = Steady state for -80mV
options = odeset; % Default ODE solver tolerances etc. for this.
% The zero on the next line is a special argument to the model (instead of
% table of clamps used in rest of project) to tell it to use sinewave and send that
% Protocol_Params.
[t, y] = ode15s(@model,[0:1:8000],y0,options,0, Model_Params, Protocol_Params);
V = sine_wave(t,Protocol_Params); % Output for plotting
IKr = Model_Params(end).*y(:,1).*y(:,2).*(V-(-88.6));


y_wang = [0.0034    0.0000    0.9925    0.0025];
[t_wang,y_wang]=ode15s(@wang_model,[0:1:8000],y_wang,options,0,Model_Params, Protocol_Params);
gKr_wang =  2.11451916137530976e-01;
o_wang = y_wang(:,4);
IKr_wang = gKr_wang.*o_wang.*(V-(-88.6));


figure
subplot(2,3,1)
plot(t./1000.0,V,'k-','LineWidth',2)
title('Sinusoidal protocol (calibration)')
xlabel('Time (s)')
ylabel('Voltage (mV)')
xlim([0 t(end)./1000])
ylim([-130 70])
set(gca,'FontSize',14)
hold on

subplot(2,3,4)
plot(t./1000.0,IKr,'-','LineWidth',2)
hold on
plot(t./1000.0,IKr_wang,'-','LineWidth',2)
xlabel('Time (s)')
ylabel('Current (nA)')
set(gca,'FontSize',14)
xlim([0 t(end)./1000])
legend('Beattie model','C-C-C-O-I','Location','southeast')

zoom = [4150 6300];

subplot(2,3,2)
patch([zoom(1) zoom(2) zoom(2) zoom(1)]./1000,[-150 -150 70-1 70-1],[0.9 0.9 0.9],'EdgeColor','none')
hold on
plot(beattie(:,1)./1000, beattie(:,2),'k-','LineWidth',2)
title('Space-filling design')
xlabel('Time (s)')
ylabel('Voltage (mV)')
xlim([0 beattie(end,1)./1000])
ylim([-130 70])
set(gca,'FontSize',14)
box on

subplot(2,3,5)
patch([zoom(1) zoom(2) zoom(2) zoom(1)]./1000,[-5 -5 15 15],[0.9 0.9 0.9],'EdgeColor','none')
hold on
plot(beattie(:,1)./1000, beattie(:,3),'-','LineWidth',2)
hold on
plot(wang(:,1)./1000, wang(:,3),'-','LineWidth',2)
xlim([0 beattie(end,1)./1000])
xlabel('Time (s)')
ylabel('Current (nA)')
set(gca,'FontSize',14)
box on

% Repeat but zoomed in
idx = intersect(find(beattie(:,1) > zoom(1)), find( beattie(:,1) < zoom(2)));
idx_wang = intersect(find(wang(:,1) > zoom(1)), find( wang(:,1) < zoom(2)));

subplot(2,3,3)
plot(beattie(idx,1)./1000, beattie(idx,2),'k-','LineWidth',2)
xlim([beattie(idx(1),1) beattie(idx(end),1)]./1000)
ylim([-130 70])
title('Space-filling design - zoom')
xlabel('Time (s)')
ylabel('Voltage (mV)')

set(gca,'FontSize',14)

subplot(2,3,6)
plot(beattie(idx,1)./1000, beattie(idx,3),'-','LineWidth',2)
hold on
plot(wang(idx_wang,1)./1000, wang(idx_wang,3),'-','LineWidth',2)
xlim([beattie(idx(1),1) beattie(idx(end),1)]./1000)
xlabel('Time (s)')
ylabel('Current (nA)')
set(gca,'FontSize',14)

