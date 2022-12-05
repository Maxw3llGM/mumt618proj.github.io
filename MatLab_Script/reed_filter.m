function [y,xf] = reed_filter(pd, xl, gr, miu, f, fs)
%Stable Reed Filter 
%   
    w = 2*pi*f;
    w2 = w^2;

    alpha = w/tan(w/(2*fs));
    alpha2 = alpha^2;

    a0 = alpha2+gr*alpha+w2;
    a1 = 2*(w2-alpha2);
    a2 = alpha2-gr*alpha+w2;

    b = [0, -4/miu];
    a = [a0, a1, a2];

    [y, xf] = filter(b,a,pd,xl);
    
%     figure(1)
%     impz(b,a)
%     grid on
%     figure(2)
%     grid on
% 
%     freqz(b,a)
end