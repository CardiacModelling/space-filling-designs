close all
clear all

load('each_cell_params.mat')
P = each_cell_params(:,5); % Loads up Beattie et al. (2018) Cell #5 parameters.

V = linspace(-120,60,1001)';

k1 = P(1).*exp(P(2).*V);
k2 = P(3).*exp(-P(4).*V);
k3 = P(5).*exp(P(6).*V);
k4 = P(7).*exp(-P(8).*V);


tau_a = 1.0./(k1+k2);
tau_r = 1.0./(k3+k4);
a_inf = k1 .* tau_a;
r_inf = k4 .* tau_r;


figure
subplot(2,1,1)
semilogy(V,tau_a)
hold on
semilogy(V, tau_r)
xlabel('V (mV)')
ylabel('\tau (ms)')
legend('$\tau_a$','$\tau_r$','Interpreter','latex')

subplot(2,1,2)
plot(V, a_inf)
hold on
plot(V, r_inf)
xlabel('V (mV)')
ylabel('steady state')
legend('$a_\infty$','$r_\infty$','Interpreter','latex')
