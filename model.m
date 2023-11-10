function dY = model(t,Y,clamp,P,varargin)
% States are a, r

if nargin==5
    C = varargin{1};
end

if (length(clamp)==1)   
    V = sine_wave(t,C);
else
	% Interpolate V at this time
	V = interp1(clamp(:,1),clamp(:,2),t,'linear',clamp(1,2));
end

k1 = P(1).*exp(P(2).*V);
k2 = P(3).*exp(-P(4).*V);
k3 = P(5).*exp(P(6).*V);
k4 = P(7).*exp(-P(8).*V);

dY = zeros(2,1);
dY(1) = +k1*(1-Y(1)) - k2*Y(1);
dY(2) = -k3*Y(2)     +k4*(1-Y(2));
