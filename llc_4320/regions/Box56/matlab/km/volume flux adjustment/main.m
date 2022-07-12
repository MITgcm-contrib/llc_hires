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

%cd ~/projects/llc/llc4320/Box56/Kayhan/2km_88l

% initialize and read grid information
nx_lr=288; ny_lr=468; nz_lr=88;                       % horizontal and vertical grid dimensions
factor_h = 8;
factor_v = 3;
DXG_lr=readbin('grid/Lowres/DXG.bin',[nx_lr ny_lr]);        % cell face separation along south cell wall (m)
DYG_lr=readbin('grid/Lowres/DYG.bin',[nx_lr ny_lr]);        % cell face separation along west cell wall (m)
DRF_lr=readbin('grid/Lowres/DRF.data',nz_lr);             % cell face separation along Z axis (m)
%RAC_lr=readbin('grid/Lowres/RAC.data',[nx_lr ny_lr]);        % horizontal cell face area (m^2)
%Depth_lr=readbin('grid/Lowres/Depth.data',[nx_lr ny_lr]);    % depth (m)
hFacS_lr=readbin('grid/Lowres/hFacS.data',[nx_lr ny_lr nz_lr]); % fraction of open south cell wall
hFacW_lr=readbin('grid/Lowres/hFacW.data',[nx_lr ny_lr nz_lr]); % fraction of open west cell wall

nx_hr=nx_lr*factor_h; ny_hr=ny_lr*factor_h; nz_hr=nz_lr*factor_v;                       % horizontal and vertical grid dimensions
DXG_hr=readbin('grid/Highres/DXG.bin',[nx_hr ny_hr]);        % cell face separation along south cell wall (m)
DYG_hr=readbin('grid/Highres/DYG.bin',[nx_hr ny_hr]);        % cell face separation along west cell wall (m)
DRF_hr=readbin('grid/Highres/DRF.data',nz_hr);             % cell face separation along Z axis (m)
%RAC_hr=readbin('grid/Highres/RAC.data',[nx_hr ny_hr]);        % horizontal cell face area (m^2)
%Depth_hr=readbin('grid/Highres/Depth.data',[nx_hr ny_hr]);    % depth (m)
hFacS_hr=readbin('grid/Highres/hFacS.data',[nx_hr ny_hr nz_hr]); % fraction of open south cell wall
hFacW_hr=readbin('grid/Highres/hFacW.data',[nx_hr ny_hr nz_hr]); % fraction of open west cell wall


% compute volume flux in m^3/s across each boundary at each time step
%ts=155520:144:224496; % timesteps to process
nt=2545;        % number of time steps to process
dT=3600;              % model output period (s)
rhoFresh=999.8;       % desnity of fresh water (kg/m^3)
U_West_lr=zeros(nt,1);   % volume flux entering west of domain (m^3/s)
U_East_lr=zeros(nt,1);   % volume flux exiting east of domain (m^3/s)
V_South_lr=zeros(nt,1);  % volume flux entering south of domain (m^3/s)
V_North_lr=zeros(nt,1);  % volume flux exiting north of domain (m^3/s)
%W_Top_lr=zeros(nt,1);    % volume flux exiting top of domain (m^3/s)
%Eta_lr=zeros(nt,1);      % mean sea surface height in domain (m)

U_West_hr=zeros(nt,1);   % volume flux entering west of domain (m^3/s)
U_East_hr=zeros(nt,1);   % volume flux exiting east of domain (m^3/s)
V_South_hr=zeros(nt,1);  % volume flux entering south of domain (m^3/s)
V_North_hr=zeros(nt,1);  % volume flux exiting north of domain (m^3/s)
%W_Top_hr=zeros(nt,1);    % volume flux exiting top of domain (m^3/s)
%Eta_hr=zeros(nt,1);      % mean sea surface height in domain (m)

U_West=readbin('grid/Highres/U_West',[ny_hr, nz_hr, nt]);
U_East=readbin('grid/Highres/U_East',[ny_hr, nz_hr, nt]);
V_South=readbin('grid/Highres/V_South',[nx_hr, nz_hr, nt]);
V_North=readbin('grid/Highres/V_North',[nx_hr, nz_hr, nt]);







%%
start_x = 9;
end_x = 0;
start_range = 9;
end_range = 8;
    
    
for t=1:nt, mydisp(t)
    % low-res volume flux computation
    hFac_lr=squeeze(hFacW_lr(2,:,:));
    tmp=readbin('grid/Lowres/U_West',[ny_lr,nz_lr],1,'real*4',t-1).*hFac_lr;
    U_West_lr(t)=DYG_lr(2,2:end-1)*tmp(2:end-1,:)*DRF_lr;
    % hi-res volume flux computation
    hFac_hr=squeeze(hFacW_hr(start_x,:,:));
    tmp=readbin('grid/Highres/U_West',[ny_hr,nz_hr],1,'real*4',t-1).*hFac_hr;
    U_West_hr(t)=DYG_hr(start_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF_hr;
    %adjustment
    U_West(:,:,t) = U_West(:,:,t) + ((U_West_lr(t)-U_West_hr(t))/(DYG_hr(start_x,start_range:(end-end_range)) * hFac_hr(start_range:(end-end_range),:) * DRF_hr));
    
    
    % low-res volume flux computation
    hFac_lr=squeeze(hFacW_lr(end,:,:));
    tmp=readbin('grid/Lowres/U_East',[ny_lr,nz_lr],1,'real*4',t-1).*hFac_lr;
    U_East_lr(t)=DYG_lr(end,2:end-1)*tmp(2:end-1,:)*DRF_lr;
    % hi-res volume flux computation
    hFac_hr=squeeze(hFacW_hr(end-end_x,:,:));
    tmp=readbin('grid/Highres/U_East',[ny_hr,nz_hr],1,'real*4',t-1).*hFac_hr;
    U_East_hr(t)=DYG_hr(end-end_x,start_range:(end-end_range))*tmp(start_range:(end-end_range),:)*DRF_hr;
    %adjustment
    U_East(:,:,t) = U_East(:,:,t) + ((U_East_lr(t)-U_East_hr(t))/(DYG_hr(end-end_x,start_range:(end-end_range)) * hFac_hr(start_range:(end-end_range),:) * DRF_hr));   


    % low-res volume flux computation
    hFac_lr=squeeze(hFacS_lr(:,2,:));
    tmp=readbin('grid/Lowres/V_South',[nx_lr,nz_lr],1,'real*4',t-1).*hFac_lr;
    V_South_lr(t)=DXG_lr(2:end-1,2)'*tmp(2:end-1,:)*DRF_lr;
    % hi-res volume flux computation
    hFac_hr=squeeze(hFacS_hr(:,start_x,:));
    tmp=readbin('grid/Highres/V_South',[nx_hr,nz_hr],1,'real*4',t-1).*hFac_hr;
    V_South_hr(t)=DXG_hr(start_range:(end-end_range),start_x)'*tmp(start_range:(end-end_range),:)*DRF_hr;
    %adjustment
    V_South(:,:,t) = V_South(:,:,t) + ((V_South_lr(t)-V_South_hr(t))/(DXG_hr(start_range:(end-end_range),start_x)' * hFac_hr(start_range:(end-end_range),:) * DRF_hr));


    % low-res volume flux computation
    hFac_lr=squeeze(hFacS_lr(:,end,:));
    tmp=readbin('grid/Lowres/V_North',[nx_lr,nz_lr],1,'real*4',t-1).*hFac_lr;
    V_North_lr(t)=DXG_lr(2:end-1,end)'*tmp(2:end-1,:)*DRF_lr;
    % hi-res volume flux computation
    hFac_hr=squeeze(hFacS_hr(:,end-end_x,:));
    tmp=readbin('grid/Highres/V_North',[nx_hr,nz_hr],1,'real*4',t-1).*hFac_hr;
    V_North_hr(t)=DXG_hr(start_range:(end-end_range),end-end_x)'*tmp(start_range:(end-end_range),:)*DRF_hr;
    %adjustment
    V_North(:,:,t) = V_North(:,:,t) + ((V_North_lr(t)-V_North_hr(t))/(DXG_hr(start_range:(end-end_range),end-end_x)' * hFac_hr(start_range:(end-end_range),:) * DRF_hr));
end


writebin("newBoundaries/U_West", U_West);
writebin("newBoundaries/U_East", U_East);
writebin("newBoundaries/V_South", V_South);
writebin("newBoundaries/V_North", V_North);
