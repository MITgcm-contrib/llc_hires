nt=480;

%U_East = h5read("U_East", "/U_East/value");
%U_West = h5read("U_West", "/U_West/value");
%V_South = h5read("V_South", "/V_South/value");
%V_North = h5read("V_North", "/V_North/value");
%SumRAC = h5read("SumRAC", "/SumRAC/value");

U_East2 = h5read("U_East2", "/U_East/value");
U_West2 = h5read("U_West2", "/U_West/value");
V_South2 = h5read("V_South2", "/V_South/value");
V_North2 = h5read("V_North2", "/V_North/value");
SumRAC2 = h5read("SumRAC2", "/SumRAC/value");



dT=3600;              % model output period (s)

figure(1), clf, orient tall, wysiwyg
subplot(411), plot(U_West2/1e6),  grid, title('volume flux entering west of domain (Sv)')
subplot(412), plot(U_East2/1e6),  grid, title('volume flux exiting east of domain (Sv)')
subplot(413), plot(V_South2/1e6), grid, title('volume flux entering south of domain (Sv)')
subplot(414), plot(V_North2/1e6), grid, title('volume flux exiting north of domain (Sv)')
%subplot(515), plot(W_Top/1e6),   grid, title('volume flux exiting top of domain (Sv)')

figure(2), clf, orient tall, wysiwyg
TotVolFlux=U_West2-U_East2+V_South2-V_North2;%-W_Top;
EtaChange=dT*cumsum(TotVolFlux)/SumRAC2;
T1=1:nt;
T2=1.5:(nt+.5);
T3=1.5:.5:nt;

tme=datenum('01-Mar-2012')+val01(:,2)/60/60/24;
EtaMean = val01(:,5);
time_should_be_included = datenum('01-Mar-2012') + ((0:3600:(20*86400-3600))/60/60/24);
EtaMean=EtaMean(ismember(tme, time_should_be_included'));

actual=EtaMean-mean(EtaMean);    % actual eta
actual=interpn(T1,actual,T3);
bovf=EtaChange'-mean(EtaChange); % based on volume flux
bovf=interpn(T2,bovf,T3);

subplot(311)
plot(TotVolFlux/1e6), grid
title('total volume flux entering domain (Sv)')

subplot(312)
diff = actual(1,1) - bovf(1,1);
plot(T3,actual,T3,bovf+diff), grid
%plot(T3,bovf), grid
legend('actual eta','based on volume flux','location','best')
%legend('eta based on volume flux','location','best')
title('domain-averaged sea surface height (m)')

subplot(313)
plot(T3,actual-bovf), grid
title('actual eta minus eta computed based on volume flux (m)')