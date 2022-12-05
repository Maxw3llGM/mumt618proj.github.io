% Clarinet Model: short description
% Longer Description
% Maxwell Gentili-Morin
clear all;

[Y,Fs] = audioread("clarinetdemo.wav");

Y = Y(Fs*0.2:length(Y),1);
C4 = 1975.53; %Midi note
fs = Fs;%22050;    % sampling rate
N = length(Y);
fr = 2205;      % resonant frequency
c = 347.23;    % speed of sound (m/sec)
rho = 1.1769;  % density of air (kg/m^3) %
T = 1/fs;
t = (0: T : (N-1)*T)*1000;

% Reed Characteristics
w = 0.01;      % width
H = 0.0004;  % equilibrium tip opening

qr = 0.3;
gr = qr*(2*pi*fr);      % damping coeffecient
miu = 0.0231;   % dynamic mass per area

% Pipe radius (m)

ra = 0.008;

% Length of pipe (m)

L = 0.025;      % not actually used, I choose a resonnant frequency independently that will determin the pipes length

% Delay Line Length

delay =  fs / fr;


% RL
b = 0.98 * [-0.221 -0.4108];
a = [1.0 -0.3801 0.0119];
z_l = [0 0];

% Pipe characteristic impedance
Zc = rho * c / (pi * ra^2);

dp = zeros(1, delay);
dm = zeros(1, delay);
pointer = 1;

env = 0:220.5/fs:1;
env = [env ones(1,N - length(env))];
vibrato = 0.1*sin(2*pi*5.735*t);
noise = 0.2*rand(1,N);
pm = env .* ones(1,N)*(miu*H*(2*pi*fr)^2) + noise + vibrato;

impulse = [(miu*H*(2*pi*fr)^2), zeros(1, N-1) ];
p = zeros(1,N);
pd = pm(1);

z_r = [];
y = zeros(1,N);
u = zeros(1,N);

for i = 1:N

  p(i) = dm(pointer);          % p- traveling into input
  
  [y(i), z_r] = reed_filter(pd, z_r, gr, miu, fr, fs);

  u(i) = volume_flow(y(i), pm(i),p(i), w, H, rho, Zc);

  % Open-end filtering
  [dm(pointer), z_l] = filter(b, a, dp(pointer), z_l);
  
  dm(pointer) = 0.95 * dm(pointer);
  dp(pointer) = p(i) + Zc*u(i);   % new p+ @ input
    % physical pressure @ input
  p(i) = p(i) + dp(pointer);

  pd = pm(i) - p(i);
  pointer = pointer + 1;       % increment "pointer"
	
  if pointer > delay           % check delay-line limits
    pointer = 1;
  end
  
end
% p = flip(env) .* p;
% Clear Figure Window and Plot
figure(1)
clf
subplot(3,1,1)

plot( t, p / impulse(1),'b')
grid
xlabel('Time (ms)')
ylabel('Gain / Zc')
title('Matlab implemented Clarinet Model')






subplot(3,1,2)
T = 1/Fs;
t = (0: T : (length(Y)-1)*T)*1000;
plot( t(1,1:Fs), Y(1:Fs,1) ,'r')
grid
xlabel('Time (ms)')
ylabel('Displacement')
title('Stk Clarinet Model')


subplot(3,1,3)

f1 = 0: fs/(N-2) : fs/2;
P1 = fft( p);
f2 = 0: Fs/(length(Y)-2) : Fs/2;
P2 = fft(Y).';

plot(f1,abs( P1(1:N/2) )/abs(max(P1)),'b',f2,abs( P2(1:N/2) )/abs(max(P2)),'r');
legend("Implemented Clarinet", "Stk Clarinet")
title("Normalized Frequency spectrum graph of the values")
ylabel("Normalize Magnitude")
xlabel("Frequency (Hz)")
v = axis;
axis( [0 10000 v(3) v(4) ] );
grid
figure(2)
clf
subplot(2,1,1)

plot( t(1,1:0.1*fs), p(1,1:0.1*fs) / impulse(1),'b')
grid
xlabel('Time (ms)')
ylabel('Gain / Zc')
title('Matlab implemented Clarinet Model')

subplot(2,1,2)
T = 1/Fs;
t = (0: T : (length(Y)-1)*T)*1000;
plot( t(1,1:0.1*Fs), Y(1:0.1*Fs,1) ,'r')
grid
xlabel('Time (ms)')
ylabel('Displacement')
title('Stk Clarinet Model')

%sound(p/impulse(1), fs);
