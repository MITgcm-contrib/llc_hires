% Some sanity checks
%
% Requires following input files:
%
% subdirectory grid contains files DXG, DYG, DRF, RAC, Depth, and hFac*
% obtained from pfe:~dmenemen/llc_4320/regions/Boxes/Box56/MITgcm/run
%
% subdirectory obcs contains files U_East, U_West, V_North, and V_South
% obtained from niagara:~dmenemen/project/Box56/run_template
%
% subdirectory UV contain U.* and V.* files obtained from
% niagara:~dmenemen/project/MITgcm/02km_088l/DT25_Mar01_Jun15
% 
cd ~/projects/llc/llc4320/Box56/Kayhan/2km_88l

% initialize and read grid information
nx=288; ny=468; nz=88;                       % horizontal and vertical grid dimensions
DRF=readbin('grid/DRF.data',nz);             % cell face separation along Z axis (m)
Depth=readbin('grid/Depth.data',[nx ny]);    % depth (m)
hFacC=readbin('grid/hFacC.data',[nx ny nz]); % fraction of open south cell wall

% verify that Depth.data, DRF.data, and hFacC.data are consistent
D2=zeros(nx,ny);
for k=1:nz
    D2=D2+hFacC(:,:,k)*DRF(k);
end
minmax(Depth-D2)
clf, orient tall, wysiwyg
subplot(311), mypcolor(Depth'); colorbar
subplot(312), mypcolor(D2'); colorbar
subplot(313), mypcolor(Depth'-D2'); colorbar

% check that obcs match actual edge velocity
ts=155520;
U=readbin(['UV/U.' myint2str(ts,10) '.data'],[nx ny nz]);
V=readbin(['UV/V.' myint2str(ts,10) '.data'],[nx ny nz]);
U_West=readbin('obcs/U_West',[ny,nz],1,'real*4',ts*25/60/60);
U_East=readbin('obcs/U_East',[ny,nz],1,'real*4',ts*25/60/60);
V_North=readbin('obcs/V_North',[nx,nz],1,'real*4',ts*25/60/60);
V_South=readbin('obcs/V_South',[nx,nz],1,'real*4',ts*25/60/60);
minmax(U(2,:,:))
minmax(U_West)
minmax(squeeze(U(2,:,:))-U_West)
minmax(U(end,:,:))
minmax(U_East)
minmax(squeeze(U(end,:,:))-U_East)
minmax(V(:,2,:))
minmax(V_South)
minmax(squeeze(V(:,2,:))-V_South)
minmax(V(:,end,:))
minmax(V_North)
minmax(squeeze(V(:,end,:))-V_North)
