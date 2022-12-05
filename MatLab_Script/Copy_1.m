

N = 20000;
fs = 44100;
c = 347.23;    % speed of sound (m/sec)
rho = 1.1769;  % density of air (kg/m^3) %

% Pipe radius (m)

ra = 0.016 / 2;

% Length of pipe (m)

L = 0.35;

% Delay Line Length

delay = round( L * fs / c);

% Pipe characteristic impedance

Zc = rho * c / (pi * ra^2);

b = 0.98 * [-0.221 -0.4108];
a = [1.0 -0.3801 0.0119];
z_l = [0 0];

% Initialize delay line and output vector

dp = zeros(1, delay);
dm = zeros(1, delay);
pointer = 1;
p = zeros(1,N);
u = [Zc, zeros(1, N-1)];


for i = 1:N

  p(i) = dm(pointer);          % p- traveling into input
  
  % Open-end filtering
  [dm(pointer), z_l] = filter(b, a, dp(pointer), z_l);
  
  dp(pointer) = p(i) + u(i);   % new p+ @ input
  p(i) = p(i) + dp(pointer);   % physical pressure @ input

  pointer = pointer + 1;       % increment "pointer"
	
  if pointer > delay           % check delay-line limits
    pointer = 1;
  end
  
end

% Clear Figure Window and Plot
clf
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

sound(y, fs)
