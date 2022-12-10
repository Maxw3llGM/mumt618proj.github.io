
tStart = tic;
T = zeros(1,100);
for i = 1:100
    tic
    CL2L();
    T(i) = toc;
end
ttime = sum(T);
ttimeavg = ttime/100;
tEnd = toc(tStart);
