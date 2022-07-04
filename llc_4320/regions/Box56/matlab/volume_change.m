% Compute volume fluxes across open boundaries and compare with sea level
% change in the domain.
%
% Requires following input files:
%
% subdirectory grid contains files DXG, DYG, DRF, RAC, Depth, and hFac*
% obtained from pfe:~dmenemen/llc_4320/regions/Boxes/Box56/MITgcm/run
%
% subdirectory obcs contains files U_East, U_West, V_North, and V_South
% obtained from niagara:~dmenemen/project/Box56/run_template
%
% subdirectory Eta contain Eta files obtained from
% niagara:~dmenemen/project/MITgcm/02km_088l/DT25_Mar01_Jun15
%
% subdirectory oceFWflx contain oceFWflx files obtained from
% niagara:~dmenemen/project/MITgcm/02km_088l/DT25_Mar01_Jun15
% 
cd ~/projects/llc/llc4320/Box56/Kayhan/2km_88l

% initialize and read grid information
nx=288; ny=468; nz=88;                       % horizontal and vertical grid dimensions
DXG=readbin('grid/DXG.data',[nx ny]);        % cell face separation along south cell wall (m)
DYG=readbin('grid/DYG.data',[nx ny]);        % cell face separation along west cell wall (m)
DRF=readbin('grid/DRF.data',nz);             % cell face separation along Z axis (m)
RAC=readbin('grid/RAC.data',[nx ny]);        % horizontal cell face area (m^2)
Depth=readbin('grid/Depth.data',[nx ny]);    % depth (m)
hFacS=readbin('grid/hFacS.data',[nx ny nz]); % fraction of open south cell wall
hFacW=readbin('grid/hFacW.data',[nx ny nz]); % fraction of open west cell wall

% compute volume flux in m^3/s across each boundary at each time step
ts=155520:144:224496; % timesteps to process
nt=length(ts);        % number of time steps to process
dT=3600;              % model output period (s)
rhoFresh=999.8;       % desnity of fresh water (kg/m^3)
U_West=zeros(nt,1);   % volume flux entering west of domain (m^3/s)
U_East=zeros(nt,1);   % volume flux exiting east of domain (m^3/s)
V_South=zeros(nt,1);  % volume flux entering south of domain (m^3/s)
V_North=zeros(nt,1);  % volume flux exiting north of domain (m^3/s)
W_Top=zeros(nt,1);    % volume flux exiting top of domain (m^3/s)
Eta=zeros(nt,1);      % mean sea surface height in domain (m)

for t=1:nt, mydisp(t)
    eta=readbin(['Eta/Eta.' myint2str(ts(t),10) '.data'],[nx ny]);
    tmp=eta.*RAC/sum(sum(RAC(2:end-1,2:end-1)));
    EtaMean(t)=sum(sum(tmp(2:end-1,2:end-1)));

    % oceFWflx is net upward freshwater flux (kg/m^2/s)
    fnm=['oceFWflx/oceFWflx.' myint2str(ts(t),10) '.data'];
    tmp=readbin(fnm,[nx ny]).*RAC/rhoFresh;
    W_Top(t)=sum(sum(tmp(2:end-1,2:end-1)));

    hFac=squeeze(hFacW(2,:,:));               % vertical cell fraction along boundary
    tmp=readbin('obcs/U_West',[ny,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    U_West(t)=DYG(2,2:end-1)*tmp(2:end-1,:)*DRF;
    
    hFac=squeeze(hFacW(end,:,:));             % vertical cell fraction along boundary
    tmp=readbin('obcs/U_East',[ny,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    U_East(t)=DYG(end,2:end-1)*tmp(2:end-1,:)*DRF;

    hFac=squeeze(hFacS(:,2,:));              % vertical cell fraction along boundary
    tmp=readbin('obcs/V_South',[nx,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    V_South(t)=DXG(2:end-1,2)'*tmp(2:end-1,:)*DRF;

    hFac=squeeze(hFacS(:,end,:));            % vertical cell fraction along boundary
    tmp=readbin('obcs/V_North',[nx,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    V_North(t)=DXG(2:end-1,end)'*tmp(2:end-1,:)*DRF;
end

figure(1), clf, orient tall, wysiwyg
subplot(511), plot(U_West/1e6),  grid, title('volume flux entering west of domain (Sv)')
subplot(512), plot(U_East/1e6),  grid, title('volume flux exiting east of domain (Sv)')
subplot(513), plot(V_South/1e6), grid, title('volume flux entering south of domain (Sv)')
subplot(514), plot(V_North/1e6), grid, title('volume flux exiting north of domain (Sv)')
subplot(515), plot(W_Top/1e6),   grid, title('volume flux exiting top of domain (Sv)')

figure(2), clf
TotVolFlux=U_West-U_East+V_South-V_North-W_Top;
EtaChange=dT*cumsum(TotVolFlux)/sum(sum(RAC(2:end-1,2:end-1)));
subplot(211), plot(TotVolFlux/1e6), grid, title('total volume flux entering domain (Sv)')
subplot(212), plot(1:nt,EtaMean-mean(EtaMean),1.5:(nt+.5),EtaChange-mean(EtaChange))
legend('actual eta','based on volume flux','location','best')
grid, title('domain-averaged sea surface height (m)')
