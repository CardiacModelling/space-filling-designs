function [ V ] = sine_wave( t, C )
%SINE_WAVE specify the sinusoidal voltage clamp protocol, runs for either a scalar or vector of times, C are the sinusoidal parameters


if isscalar(t)
    if (t>=0 && t<250)
        V = -80;
    elseif (t>=250 && t<300)
        V = -120;
    elseif (t>=300 && t<500)
        V = -80;
    elseif (t>=500 && t<1500)
        V = 40;
    elseif (t>=1500 && t<2000)
        V = -120;
    elseif (t>=2000 && t<3000)
        V = -80;
    elseif (t>=3000 && t<6500)
        V=-30+C(1)*(sin(2*pi*C(4)*(t-2500))) + C(2)*(sin(2*pi*C(5)*(t-2500))) + C(3)*(sin(2*pi*C(6)*(t-2500)));
    elseif (t>=6500 && t<7500)
        V=-120;
    else
        V = -80;
    end
else
    V = zeros(length(t),1);
    for i=1:length(t)
        V(i) = sine_wave(t(i),C);
    end
end
end

