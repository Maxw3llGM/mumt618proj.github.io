function [u] = volume_flow(y,pm, p0n,w,H,phi,Zc)
%VOLUME_FLOW Summary of this function goes here
%   Detailed explanation goes here
    yd = y + H;
    
    A = pm - 2*p0n;

    B = w*(yd*sqrt(2/phi));

    if yd < 0
        u = 0;
    else
        u = 0.5*(B*(sqrt((Zc*B)^2+4*A))-Zc*B^2)*sign(A);
    end
end

