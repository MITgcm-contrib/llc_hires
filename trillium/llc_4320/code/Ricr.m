phi=-pi/2:.001:pi/2;
deg=rad2deg(phi);
rotationPeriod=86164;
omega=2*pi/rotationPeriod;
coriol=2*omega*sin(phi);
Ricr=0.3;
RicrEq=0.2;
RicrLoc=Ricr+0*coriol;
clf
plot(deg,RicrLoc,'linewidth',4)
axis([-90 90 .19 .31])

coriolEq=1.27e-5;
coriolHL=5.08e-5;
dcoriol=coriolHL-coriolEq;
dRicr=Ricr-RicrEq;

it=find(coriol>-coriolHL&coriol<-coriolEq);
RicrLoc(it)=RicrEq+dRicr*(1+cos(pi*(coriol(it)+coriolHL)/dcoriol))/2;
clf
plot(deg,RicrLoc,'linewidth',4)
axis([-90 90 .19 .31])

it=find(coriol>=-coriolEq&coriol<=coriolEq);
RicrLoc(it)=RicrEq;
clf
plot(deg,RicrLoc,'linewidth',4)
axis([-90 90 .19 .31])

it=find(coriol>coriolEq&coriol<coriolHL);
RicrLoc(it)=Ricr-dRicr*(1+cos(pi*(coriol(it)-coriolEq)/dcoriol))/2;
clf
plot(deg,RicrLoc,'linewidth',4)
axis([-90 90 .19 .31])

%%%%%%%%%%%%%%%%%%%
clear
YC=-90:.1:90;
Ricr=0.3;
RicrEq=0.2;
RicrLoc=Ricr+0*YC;
YC_EQ=5;
YC_HL=20;
DelYC=YC_HL-YC_EQ;
DelRicr=Ricr-RicrEq;

it=find(YC>-YC_HL&YC<-YC_EQ);
RicrLoc(it)=RicrEq+DelRicr*(1+cos(pi*(YC(it)+YC_HL)/DelYC))/2;

it=find(YC>=-YC_EQ&YC<=YC_EQ);
RicrLoc(it)=RicrEq;

it=find(YC>YC_EQ&YC<YC_HL);
RicrLoc(it)=Ricr-DelRicr*(1+cos(pi*(YC(it)-YC_EQ)/DelYC))/2;

figure(2)
clf
plot(YC,RicrLoc,'linewidth',4)
axis([-90 90 .19 .31])
