N = 20000;
fs = 44100;
c = 347.23;    % speed of sound (m/sec)
rho = 1.1769;  % density of air (kg/m^3) %

L = 0.4572;
r = 0.0238125 / 2;

f = c/L;
delay = round( fs / f);
Zc = rho * c / (pi * r^2);

% Reed Filter\
w = 1;
H = 0;
phi = 1;
wr = 2*pi*f;
alpha = wr/tan(wr/(2*fs));
gr = 2;
miur = 1;
ar = [alpha^2+gr*alpha+wr^2,2*(wr^2-alpha^2),alpha^2-gr*alpha+wr^2];
br = [0,-4/miur];
z_r = [];


b = 0.98 * [-0.221 -0.4108];
a = [1.0 -0.3801 0.0119];
z_l = [];

d = zeros(1, 2*delay);

pointer = 1;

p = zeros(1,N);
pm = 0:0.005:0.85; %determined from clarinet model
pmend = 0.85:0.005:0;
pm = [pm 0.85 * ones(1,N-2*length(pm)) pmend];
pdelta = zeros(1,N);

y = zeros(1,N);
u = [Zc, zeros(1, N)];

for i = 1:N
    pdelta(pointer) = -pm(pointer);

    [y(pointer), z_r] = filter(br, ar, d(pointer), z_r);

    A = pm(pointer) - 2*p(pointer);
    B = w*(y(pointer)+H)*sqrt(2/phi);
    u(pointer) = 0.5*(B*sqrt((Zc*B)^2+4*A-Zc*B^2))*sign(A); 
    
    [val, z_l] = filter(b, a, d(pointer), z_l);

    pdelta(pointer) = pdelta(pointer) - val;

    d(pointer) = val;
    
    p(pointer) = 2*val + Zc*u(pointer);


%   p(i) = 2 * d(pointer) + Zc*u;          % p- traveling into inpu
%   
%   % Open-end filtering
%   [dm(pointer), z_l] = filter(b, a, dp(pointer), z_l);
%   
%   dp(pointer) = p(i) + u(i);   % new p+ @ input
%   p(i) = p(i) + dp(pointer);   % physical pressure @ input
    
  
  pointer = pointer + 1;       % increment "pointer"
	
  if pointer > 2 * delay           % check delay-line limits
    pointer = 1;
  end
  
end


subplot(2,1,1)
T = 1/fs;
t = (0: T : (N-1)*T) * 1000;
plot( t, p / Zc )
grid
xlabel('Time (ms)')
ylabel('Gain / Zc')
title('Impulse Response of Pipe')
xlim([0 20]);

subplot(2,1,2)
f = 0: fs/(N-2) : fs/2;
P = fft( p );
plot( f, abs( P(1:N/2) / Zc ) )
grid
xlabel('Frequency (Hz)')
ylabel('Magnitude / Zc')
title('Input Impedance of Pipe')
v = axis;
axis( [0 10000 v(3) v(4) ] );

sound(p,fs)