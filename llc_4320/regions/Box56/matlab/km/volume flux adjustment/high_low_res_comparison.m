path =  "/Users/kayhanmomeni/Documents/PhD/MITgcm/Volume flux adjustment/grid/Lowres/" ;
% initialize and read grid information
nx=288; ny=468; nz=88;                       % horizontal and vertical grid dimensions
DXG=readbin(strcat(path, 'DXG.bin'),[nx ny]);        % cell face separation along south cell wall (m)
DYG=readbin(strcat(path, 'DYG.bin'),[nx ny]);        % cell face separation along west cell wall (m)
DRF=readbin(strcat(path, 'DRF.data'),nz);             % cell face separation along Z axis (m)
RAC=readbin(strcat(path, 'RAC.data'),[nx ny]);        % horizontal cell face area (m^2)
Depth=readbin(strcat(path, 'Depth.data'),[nx ny]);    % depth (m)
hFacS=readbin(strcat(path, 'hFacS.data'),[nx ny nz]); % fraction of open south cell wall
hFacW=readbin(strcat(path, 'hFacW.data'),[nx ny nz]); % fraction of open west cell wall

% compute volume flux in m^3/s across each boundary at each time step
%ts=155520:144:224496; % timesteps to process
nt=2545;        % number of time steps to process
dT=3600;              % model output period (s)
rhoFresh=999.8;       % desnity of fresh water (kg/m^3)
U_West=zeros(nt,1);   % volume flux entering west of domain (m^3/s)
U_East=zeros(nt,1);   % volume flux exiting east of domain (m^3/s)
V_South=zeros(nt,1);  % volume flux entering south of domain (m^3/s)
V_North=zeros(nt,1);  % volume flux exiting north of domain (m^3/s)
W_Top=zeros(nt,1);    % volume flux exiting top of domain (m^3/s)
Eta=zeros(nt,1);      % mean sea surface height in domain (m)

for t=1:nt, mydisp(t)

    hFac=squeeze(hFacW(2,:,:));               % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'U_West'),[ny,nz],1,'real*4',t-1).*hFac;
    U_West(t)=DYG(2,2:end-1)*tmp(2:end-1,:)*DRF;
    
    hFac=squeeze(hFacW(end,:,:));             % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'U_East'),[ny,nz],1,'real*4',t-1).*hFac;
    U_East(t)=DYG(end,2:end-1)*tmp(2:end-1,:)*DRF;

    hFac=squeeze(hFacS(:,2,:));              % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'V_South'),[nx,nz],1,'real*4',t-1).*hFac;
    V_South(t)=DXG(2:end-1,2)'*tmp(2:end-1,:)*DRF;

    hFac=squeeze(hFacS(:,end,:));            % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'V_North'),[nx,nz],1,'real*4',t-1).*hFac;
    V_North(t)=DXG(2:end-1,end)'*tmp(2:end-1,:)*DRF;    
 end

SumRAC = sum(sum(RAC(2:end-1,2:end-1)));

U_East1=U_East;
U_West1=U_West;
V_South1=V_South;
V_North1=V_North;
SumRAC1=SumRAC;



path =  "/Users/kayhanmomeni/Documents/PhD/MITgcm/Volume flux adjustment/grid/Highres/" ;
newBoundaries = "/Users/kayhanmomeni/Documents/PhD/MITgcm/Volume flux adjustment/newBoundaries/" ;

% initialize and read grid information
nx=288*8; ny=468*8; nz=88*3;                       % horizontal and vertical grid dimensions
DXG=readbin(strcat(path, 'DXG.bin'),[nx ny]);        % cell face separation along south cell wall (m)
DYG=readbin(strcat(path, 'DYG.bin'),[nx ny]);        % cell face separation along west cell wall (m)
DRF=readbin(strcat(path, 'DRF.data'),nz);             % cell face separation along Z axis (m)
RAC=readbin(strcat(path, 'RAC.data'),[nx ny]);        % horizontal cell face area (m^2)
Depth=readbin(strcat(path, 'Depth.data'),[nx ny]);    % depth (m)
hFacS=readbin(strcat(path, 'hFacS.data'),[nx ny nz]); % fraction of open south cell wall
hFacW=readbin(strcat(path, 'hFacW.data'),[nx ny nz]); % fraction of open west cell wall

% compute volume flux in m^3/s across each boundary at each time step
%ts=155520:144:224496; % timesteps to process
nt=2545;        % number of time steps to process
dT=3600;              % model output period (s)
rhoFresh=999.8;       % desnity of fresh water (kg/m^3)
U_West=zeros(nt,1);   % volume flux entering west of domain (m^3/s)
U_East=zeros(nt,1);   % volume flux exiting east of domain (m^3/s)
V_South=zeros(nt,1);  % volume flux entering south of domain (m^3/s)
V_North=zeros(nt,1);  % volume flux exiting north of domain (m^3/s)
W_Top=zeros(nt,1);    % volume flux exiting top of domain (m^3/s)
Eta=zeros(nt,1);      % mean sea surface height in domain (m)

for t=1:nt, mydisp(t)
    %eta=readbin(['Eta/Eta.' myint2str(ts(t),10) '.data'],[nx ny]);
    %tmp=eta.*RAC/sum(sum(RAC(2:end-1,2:end-1)));
    %EtaMean(t)=sum(sum(tmp(2:end-1,2:end-1)));

    % oceFWflx is net upward freshwater flux (kg/m^2/s)
    %fnm=['oceFWflx/oceFWflx.' myint2str(ts(t),10) '.data'];
    %tmp=readbin(fnm,[nx ny]).*RAC/rhoFresh;
    %W_Top(t)=sum(sum(tmp(2:end-1,2:end-1)));

    
    
    %hFac=squeeze(hFacW(2,:,:));               % vertical cell fraction along boundary
    %tmp=readbin(strcat(path, 'U_West_3744.264.2545'),[ny,nz],1,'real*4',t-1).*hFac;
    %U_West(t)=DYG(2,2:end-1)*tmp(2:end-1,:)*DRF;
    
    %hFac=squeeze(hFacW(end,:,:));             % vertical cell fraction along boundary
    %tmp=readbin(strcat(path, 'U_East_3744.264.2545'),[ny,nz],1,'real*4',t-1).*hFac;
    %U_East(t)=DYG(end,2:end-1)*tmp(2:end-1,:)*DRF;

    %hFac=squeeze(hFacS(:,2,:));              % vertical cell fraction along boundary
    %tmp=readbin(strcat(path, 'V_South_2304.264.2545'),[nx,nz],1,'real*4',t-1).*hFac;
    %V_South(t)=DXG(2:end-1,2)'*tmp(2:end-1,:)*DRF;

    %hFac=squeeze(hFacS(:,end,:));            % vertical cell fraction along boundary
    %tmp=readbin(strcat(path, 'V_North_2304.264.2545'),[nx,nz],1,'real*4',t-1).*hFac;
    %V_North(t)=DXG(2:end-1,end)'*tmp(2:end-1,:)*DRF;    
    
    
    start_x = 9;
    end_x = 0;


    start_range = 9;
    end_range = 9;

    
    
    hFac=squeeze(hFacW(start_x,:,:));               % vertical cell fraction along boundary
    tmp=readbin(strcat(newBoundaries, 'U_West'),[ny,nz],1,'real*4',t-1).*hFac;
    U_West(t)=DYG(start_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF;
    
    hFac=squeeze(hFacW(end-end_x,:,:));             % vertical cell fraction along boundary
    tmp=readbin(strcat(newBoundaries, 'U_East'),[ny,nz],1,'real*4',t-1).*hFac;
    U_East(t)=DYG(end-end_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF;

    hFac=squeeze(hFacS(:,start_x,:));              % vertical cell fraction along boundary
    tmp=readbin(strcat(newBoundaries, 'V_South'),[nx,nz],1,'real*4',t-1).*hFac;
    V_South(t)=DXG(start_range:(end-end_range),start_x)'*tmp(start_range:(end-end_range),:)*DRF;

    hFac=squeeze(hFacS(:,end-end_x,:));            % vertical cell fraction along boundary
    tmp=readbin(strcat(newBoundaries, 'V_North'),[nx,nz],1,'real*4',t-1).*hFac;
    V_North(t)=DXG(start_range:(end-end_range),end-end_x)'*tmp(start_range:(end-end_range),:)*DRF;
end

SumRAC = sum(sum(RAC(start_range:(end-end_range),start_range:(end-end_range))));

U_East2=U_East;
U_West2=U_West;
V_South2=V_South;
V_North2=V_North;
SumRAC2=SumRAC;















figure(1), clf, orient tall, wysiwyg
subplot(411)
plot(U_West1/1e6)
hold all
plot(U_West2/1e6)
grid
title('volume flux entering west of domain (Sv)')

subplot(412)
plot(U_East1/1e6)
hold all
plot(U_East2/1e6)
grid
title('volume flux exiting east of domain (Sv)')

subplot(413)
plot(V_South1/1e6)
hold all
plot(V_South2/1e6)
grid
title('volume flux entering south of domain (Sv)')

subplot(414)
plot(V_North1/1e6)
hold all
plot(V_North2/1e6)
grid
title('volume flux exiting north of domain (Sv)')


figure(2), clf, orient tall, wysiwyg
TotVolFlux1=U_West1-U_East1+V_South1-V_North1;%-W_Top;
EtaChange1=dT*cumsum(TotVolFlux1)/SumRAC1;
TotVolFlux2=U_West2-U_East2+V_South2-V_North2;%-W_Top;
EtaChange2=dT*cumsum(TotVolFlux2)/SumRAC2;
plot(EtaChange1)
hold all
plot(EtaChange2)
%xlim([1, 480])
