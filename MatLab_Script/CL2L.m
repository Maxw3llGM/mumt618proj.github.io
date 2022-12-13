% Clarinet Model: short description
% Longer Description
% Maxwell Gentili-Morin
% Opening the reference stk sound
[Y,Fs] = audioread("clarinetdemo.wav");
Y = Y(Fs*0.2:length(Y),1);

% General Variables
fs = Fs;                % sampling Frequency
fr = 2205;              % resonant frequency
note = 1939.53;         % Midi note
c = 347.23;             % speed of sound (m/sec)
rho = 1.1769;           % density of air (kg/m^3) %
% Reed Characteristics
w = 0.01;               % reed width
H = 0.0004;             % reed equilibrium tip opening
qr = 0.3;
gr = qr*(2*pi*fr);      % reed damping coeffecient
miu = 0.0231;           % reed dynamic mass per area
% Mouthpiece Characteristics
pm = miu*H*(2*pi*fr)^2; % mouth pressure
% Pipe radius (m)
ra = 0.008;


% Delay Line Length
N = length(Y);
T = 1/fs;
t = (0: T : (N-1)*T)*1000;

M =  fs / note;
delay = floor(M);
dlength = delay + 50;
delta = M - delay;
delayLp = zeros(1,dlength);
delayLm = zeros(1,dlength);

xnmp = 0;
xnmm = 0;

wptr = 1;
rptr = wptr - delay;
if rptr <= 0
    rptr = rptr + dlength;
end

% RL
b = 0.98 * [-0.221 -0.4108];
a = [1.0 -0.3801 0.0119];
z_l = [0 0];

% Pipe characteristic impedance
Zc = rho * c / (pi * ra^2);


env = 0:220.5/fs:1;
env = [env ones(1,N - length(env))];
vibrato = 0.1*sin(2*pi*5.735*t);
noise = 0.2*rand(1,N);
pm = env .* ones(1,N)*(pm) + noise + vibrato;

impulse = [(miu*H*(2*pi*fr)^2), zeros(1, N-1) ];
p = zeros(1,N);
pd = pm(1);

z_r = [];
y = zeros(1,N);
u = zeros(1,N);

wf = 2*pi*fr;
wf2 = wf^2;

alpha = wf/tan(wf/(2*fs));
alpha2 = alpha^2;

a0 = alpha2+gr*alpha+wf2;
a1 = 2*(wf2-alpha2);
a2 = alpha2-gr*alpha+wf2;

brf = [0, -4/miu];
arf = [a0, a1, a2];

k = sqrt(2/rho);

for i = 1:N
    
    mvar = delayLm(rptr);
    p(i) = mvar + delta * (xnmm-mvar);
    xnmm = mvar;

    [y(i), z_r] = reed_filter(pd, z_r, arf, brf);
    u(i) = volume_flow(y(i), pm(i),p(i), w, H, k, Zc);

    pvar = delayLp(rptr);
    % Open-end filtering
    [delayLm(wptr), z_l] = filter(b, a, pvar + delta * (xnmp-pvar), z_l);
    xnmp = pvar;
    delayLm(wptr) = delayLm(wptr);
    
    delayLp(wptr) = p(i) + Zc*u(i);
    p(i) = p(i) + delayLp(wptr);
    

    pd = pm(i) - p(i);

    % Increment the pointer and check end conditions.
    wptr = wptr + 1;
    rptr = rptr + 1;
    if wptr > dlength, wptr = 1; end
    if rptr > dlength, rptr = 1; end
end
% % Clear Figure Window and Plot
% figure(1)
% clf
% subplot(3,1,1)
% 
% plot( t, p / impulse(1),'b')
% grid
% xlabel('Time (ms)')
% ylabel('Gain / Zc')
% title('Matlab implemented Clarinet Model')
% 
% 
% 
% f1 = 0: fs/(N-2) : fs/2;
% P1 = fft( p);
% 
% subplot(3,1,2)
% T = 1/Fs;
% t = (0: T : (length(Y)-1)*T)*1000;
% plot( t(1,1:Fs), Y(1:Fs,1) ,'r')
% grid
% xlabel('Time (ms)')
% ylabel('Displacement')
% title('Stk Clarinet Model')
% 
% 
% f2 = 0: Fs/(length(Y)-2) : Fs/2;
% P2 = fft(Y);
% 
% 
% subplot(3,1,3)
% P2 = P2.';
% 
% 
% plot(f1,abs( P1(1:N/2) )/abs(max(P1)),'b',f2,abs( P2(1:N/2) )/abs(max(P2)),'r');
% % plot(f1,abs( P1(1:N/2) )/Zc,'b');
% legend("Implemented Clarinet", "Stk Clarinet")
% title("Normalized Frequency spectrum graph of the values")
% ylabel("Normalize Magnitude")
% xlabel("Frequency (Hz)")
% v = axis;
% axis( [0 10000 v(3) v(4) ] );
% grid
% 
% plot(f1,abs( P1(1:N/2) )/abs(max(P1)),'b',f2,abs( P2(1:N/2) )/abs(max(P2)),'r');
% % plot(f1,abs( P1(1:N/2) )/Zc,'b');
% legend("Implemented Clarinet", "Stk Clarinet")
% title("Normalized Frequency spectrum graph of the values")
% ylabel("Normalize Magnitude")
% xlabel("Frequency (Hz)")
% v = axis;
% axis( [0 10000 v(3) v(4) ] );
% grid
% 
% figure(2)
% clf
% subplot(2,1,1)
% 
% plot( t(1,1:0.1*fs), p(1,1:0.1*fs) / impulse(1),'b')
% grid
% xlabel('Time (ms)')
% ylabel('Gain / Zc')
% title('Matlab implemented Clarinet Model')
% 
% subplot(2,1,2)
% T = 1/Fs;
% t = (0: T : (length(Y)-1)*T)*1000;
% plot( t(1,1:0.1*Fs), Y(1:0.1*Fs,1) ,'r')
% grid
% xlabel('Time (ms)')
% ylabel('Displacement')
% title('Stk Clarinet Model')
% 
% audiowrite("clarinetmatlab.wav",0.95*p/impulse(1),fs)

%%
% sound(p/impulse(1), fs);

