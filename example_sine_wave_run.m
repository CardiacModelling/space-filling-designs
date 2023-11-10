close all
clear all

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

a = y(:,1);
r = y(:,2);

N_boxes = 6;
box_hits = zeros(N_boxes,N_boxes,N_boxes);
box_hits = update_box_hits(box_hits, t, y, V);
total_hits = sum(sum(sum(box_hits>1)));
fprintf('The sine wave protocol hits %i/%i boxes (%.1f%%).\n',total_hits,N_boxes^3,100*total_hits/(N_boxes^3))

figure
subplot(4,1,1)
plot(t, V,'k-','LineWidth',1.5)
xlabel('Time (ms)')
ylabel('Voltage (mV)')

subplot(4,1,2)
plot(t,y,'LineWidth',1.5)
legend('a','r')
xlabel('Time (ms)')
ylabel('Gating Variable')

IKr = Model_Params(end).*y(:,1).*y(:,2).*(V-(-88.6));

subplot(4,1,3)
plot(t,IKr,'b-','LineWidth',1.5)
xlabel('Time (ms)')
ylabel('g*O*(V-E_K)')

subplot(4,1,4)
plot(a,r,'b-','LineWidth',1.5)
xlabel('activation a')
ylabel('recovery r')

figure
plot3(a,r,V,'b-','LineWidth',1.5)
xlabel('activation a')
ylabel('recovery r')
zlabel('Voltage (mV)')
zlim([-120 60])