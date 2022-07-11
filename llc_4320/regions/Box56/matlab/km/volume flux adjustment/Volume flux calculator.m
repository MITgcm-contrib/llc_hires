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
path =  "/home/p/peltier/momenika/scratch/MITgcm/projects/Box56_250m-264l_KPP-back-off_DoublyCorrectedBoundaries/run/" ;

% initialize and read grid information
nx=288*8; ny=468*8; nz=88*3;                       % horizontal and vertical grid dimensions
DXG=readbin(strcat(path, 'DXG.data'),[nx ny]);        % cell face separation along south cell wall (m)
DYG=readbin(strcat(path, 'DYG.data'),[nx ny]);        % cell face separation along west cell wall (m)
DRF=readbin(strcat(path, 'DRF.data'),nz);             % cell face separation along Z axis (m)
RAC=readbin(strcat(path, 'RAC.data'),[nx ny]);        % horizontal cell face area (m^2)
Depth=readbin(strcat(path, 'Depth.data'),[nx ny]);    % depth (m)
hFacS=readbin(strcat(path, 'hFacS.data'),[nx ny nz]); % fraction of open south cell wall
hFacW=readbin(strcat(path, 'hFacW.data'),[nx ny nz]); % fraction of open west cell wall

% compute volume flux in m^3/s across each boundary at each time step
%ts=155520:144:224496; % timesteps to process
nt=480;        % number of time steps to process
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
    
    
    factor = 8;
    
    
    
    start_x = 9;
    end_x = 7;


    start_range = 7;
    end_range = 9;

    
    
    hFac=squeeze(hFacW(start_x,:,:));               % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'U_West_3744.264.2545'),[ny,nz],1,'real*4',t-1).*hFac;
    U_West(t)=DYG(start_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF;
    
    hFac=squeeze(hFacW(end-end_x,:,:));             % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'U_East_3744.264.2545'),[ny,nz],1,'real*4',t-1).*hFac;
    U_East(t)=DYG(end-end_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF;

    hFac=squeeze(hFacS(:,start_x,:));              % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'V_South_2304.264.2545'),[nx,nz],1,'real*4',t-1).*hFac;
    V_South(t)=DXG(start_range:(end-end_range),start_x)'*tmp(start_range:(end-end_range),:)*DRF;

    hFac=squeeze(hFacS(:,end-end_x,:));            % vertical cell fraction along boundary
    tmp=readbin(strcat(path, 'V_North_2304.264.2545'),[nx,nz],1,'real*4',t-1).*hFac;
    V_North(t)=DXG(start_range:(end-end_range),end-end_x)'*tmp(start_range:(end-end_range),:)*DRF;
end

SumRAC = sum(sum(RAC(start_range:(end-end_range),start_range:(end-end_range))));

save -hdf5 grid/U_East2 U_East
save -hdf5 grid/U_West2 U_West
save -hdf5 grid/V_South2 V_South
save -hdf5 grid/V_North2 V_North
save -hdf5 grid/SumRAC2 SumRAC
